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
