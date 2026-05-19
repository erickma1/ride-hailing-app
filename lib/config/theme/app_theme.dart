import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF1F1F1F);
  static const Color accent = Color(0xFF00D4FF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color success = Color(0xFF51CF66);
  static const Color error = Color(0xFFFF6B6B);
  
  // Ghana Colors
  static const Color ghanaGold = Color(0xFFCEA946);
  static const Color ghanaGreen = Color(0xFF007A5E);
  static const Color ghanaRed = Color(0xFFCE1126);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: primary,
    );
  }
}
