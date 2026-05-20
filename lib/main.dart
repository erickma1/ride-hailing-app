import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      getPages: AppRoutes.pages,
      home: _buildHome(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildHome() {
    final authController = Get.find<AuthController>();

    return Obx(() {
      // If user is logged in, show home screen
      if (authController.isLoggedIn.value &&
          authController.user.value != null) {
        return HomeScreen();
      }
      // Otherwise show login screen
      return const LoginScreen();
    });
  }
}
