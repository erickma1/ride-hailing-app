import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final user = Rx<UserModel?>(null);
  final verificationId = ''.obs;
  final phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    _authService.authStateChanges.listen((User? currentUser) async {
      if (currentUser != null) {
        isLoggedIn.value = true;
        await _loadUserProfile(currentUser.uid);
      } else {
        isLoggedIn.value = false;
        user.value = null;
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final userProfile = await _authService.getUserProfile(uid);
      user.value = userProfile;
    } catch (e) {
      print('Profile load error: $e');
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    try {
      isLoading.value = true;

      final cred = await _authService.signUpWithEmail(email, password);

      final newUser = UserModel(
        uid: cred.user!.uid,
        phoneNumber: '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        isDriver: false,
        createdAt: DateTime.now(),
      );

      await _authService.createUserProfile(newUser);
      user.value = newUser;
      isLoggedIn.value = true;

      Get.snackbar('Success', 'Account created!');
      Get.offNamed('/home');
    } catch (e) {
      print('SignUp error: $e');
      Get.snackbar('Error', 'Sign up failed: ${e.toString().substring(0, 50)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;

      await _authService.signInWithEmail(email, password);

      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        isLoggedIn.value = true;
        await _loadUserProfile(currentUser.uid);
        Get.offNamed('/home');
      }
    } catch (e) {
      print('SignIn error: $e');
      Get.snackbar('Error', 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOTP(String phone) async {
    try {
      isLoading.value = true;
      phoneNumber.value = phone;
      await _authService.sendOTP(phone);
    } catch (e) {
      Get.snackbar('Error', 'OTP send failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      await _authService.verifyOTP(verificationId.value, otp);
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        isLoggedIn.value = true;
        await _loadUserProfile(currentUser.uid);
        Get.offNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Error', 'OTP verification failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      await _authService.updateUserProfile(
          updatedUser.uid, updatedUser.toMap());
      user.value = updatedUser;
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', 'Update failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      user.value = null;
      isLoggedIn.value = false;
      Get.offNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed');
    }
  }
}
