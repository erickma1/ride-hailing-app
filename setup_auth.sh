#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating Authentication System...${NC}\n"

# Create auth service
cat > lib/core/services/auth_service.dart << 'EOF'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent: $verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout');
        },
      );
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  // Verify OTP
  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Sign up with email
  Future<UserCredential> signUpWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  // Sign in with email
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  // Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error checking user: $e');
    }
  }
}
EOF
echo -e "${GREEN}✓ Created auth_service.dart${NC}"

# Create auth controller
cat > lib/presentation/controllers/auth_controller.dart << 'EOF'
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_strings.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final user = Rx<UserModel?>(null);
  final verificationId = ''.obs;
  final phoneNumber = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Check auth status
  void checkAuthStatus() {
    _authService.authStateChanges.listen((User? currentUser) {
      if (currentUser != null) {
        isLoggedIn.value = true;
        loadUserProfile(currentUser.uid);
      } else {
        isLoggedIn.value = false;
        user.value = null;
      }
    });
  }

  // Send OTP
  Future<void> sendOTP(String phone) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      phoneNumber.value = phone;
      await _authService.sendOTP(phone);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final credential = await _authService.verifyOTP(verificationId.value, otp);
      
      // Check if user exists
      bool exists = await _authService.userExists(credential.user!.uid);
      
      if (exists) {
        await loadUserProfile(credential.user!.uid);
        Get.offNamed('/home');
      } else {
        // New user - go to profile creation
        Get.offNamed('/profile-setup',
            arguments: {'uid': credential.user!.uid, 'phone': phoneNumber.value});
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with email
  Future<void> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _authService.signUpWithEmail(email, password);
      
      final newUser = UserModel(
        uid: credential.user!.uid,
        phoneNumber: '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        isDriver: false,
        createdAt: DateTime.now(),
      );

      await _authService.createUserProfile(newUser);
      user.value = newUser;
      
      Get.snackbar('Success', AppStrings.success,
          snackPosition: SnackPosition.BOTTOM);
      Get.offNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmail(email, password);
      await loadUserProfile(_authService.currentUser!.uid);
      
      Get.offNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Load user profile
  Future<void> loadUserProfile(String uid) async {
    try {
      final userProfile = await _authService.getUserProfile(uid);
      user.value = userProfile;
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      await _authService.updateUserProfile(
          updatedUser.uid, updatedUser.toMap());
      user.value = updatedUser;
      Get.snackbar('Success', 'Profile updated',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      user.value = null;
      Get.offNamed('/login');
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
EOF
echo -e "${GREEN}✓ Created auth_controller.dart${NC}"

# Create login screen
cat > lib/presentation/screens/auth/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../config/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPhoneMode = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your journey, our priority',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tab selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPhoneMode = true),
                      child: Column(
                        children: [
                          Text(
                            'Phone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isPhoneMode
                                  ? AppTheme.accentColor
                                  : Colors.grey,
                            ),
                          ),
                          if (_isPhoneMode)
                            Container(
                              height: 3,
                              margin: const EdgeInsets.only(top: 8),
                              color: AppTheme.accentColor,
                            )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPhoneMode = false),
                      child: Column(
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !_isPhoneMode
                                  ? AppTheme.accentColor
                                  : Colors.grey,
                            ),
                          ),
                          if (!_isPhoneMode)
                            Container(
                              height: 3,
                              margin: const EdgeInsets.only(top: 8),
                              color: AppTheme.accentColor,
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Phone mode
              if (_isPhoneMode) ...[
                const Text(
                  AppStrings.enterPhoneNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: AppStrings.phoneNumberHint,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '🇬🇭 +233',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () {
                                if (_phoneController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter phone number',
                                  );
                                  return;
                                }
                                authController
                                    .sendOTP(_phoneController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                    )),
              ],

              // Email mode
              if (!_isPhoneMode) ...[
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () {
                                authController.signInWithEmail(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                    )),
              ],

              const SizedBox(height: 20),
              // Sign up link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF
echo -e "${GREEN}✓ Created login_screen.dart${NC}"

# Create signup screen
cat > lib/presentation/screens/auth/signup_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../config/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'First Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'John',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Last Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                Get.snackbar('Error', 'Passwords do not match');
                                return;
                              }
                              authController.signUpWithEmail(
                                _emailController.text,
                                _passwordController.text,
                                _firstNameController.text,
                                _lastNameController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  )),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF
echo -e "${GREEN}✓ Created signup_screen.dart${NC}"

# Create OTP verification screen
cat > lib/presentation/screens/auth/otp_verification_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../config/theme/app_theme.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    'We sent a 6-digit code to ${authController.phoneNumber.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: AppTheme.accentColor.withOpacity(0.1),
                  activeColor: AppTheme.accentColor,
                  inactiveColor: Colors.grey.shade300,
                  inactiveFillColor: Colors.white,
                ),
                controller: _otpController,
                onChanged: (String value) {},
              ),
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              if (_otpController.text.length == 6) {
                                authController.verifyOTP(_otpController.text);
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please enter 6-digit OTP',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  )),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive code? "),
                    GestureDetector(
                      onTap: () {
                        Get.snackbar('Info', 'Resending OTP...');
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF
echo -e "${GREEN}✓ Created otp_verification_screen.dart${NC}"

# Update app_routes.dart
cat > lib/presentation/routes/app_routes.dart << 'EOF'
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';

  static List<GetPage> get pages => [
        GetPage(
          name: login,
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: signup,
          page: () => const SignupScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: otpVerification,
          page: () => const OTPVerificationScreen(),
          transition: Transition.fadeIn,
        ),
      ];
}
EOF
echo -e "${GREEN}✓ Updated app_routes.dart${NC}"

echo -e "\n${GREEN}✓✓✓ Authentication System created successfully! ✓✓✓${NC}"
EOF