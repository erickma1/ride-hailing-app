import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneVerification = '/phone-verification';
  static const String home = '/home';
  static const String requestRide = '/request-ride';
  static const String rideTracking = '/ride-tracking';
  static const String rideHistory = '/ride-history';
  static const String profile = '/profile';
  static const String payment = '/payment';

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
          name: phoneVerification,
          page: () => const OTPVerificationScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: home,
          page: () => HomeScreen(),
          transition: Transition.fadeIn,
        ),
      ];
}
