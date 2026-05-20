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
