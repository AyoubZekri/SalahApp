import 'package:flutter/material.dart';

class AppColor {
  // Existing colors for backward compatibility
  static const Color primarycolor = Color.fromARGB(255, 242, 243, 245);
  static const Color white = Colors.white;
  static const Color backgroundcolor = Color(0xFF4F46E5);
  static const Color grey = Color.fromRGBO(141, 140, 140, 1);
  static const Color red = Colors.red;
  static const Color black = Colors.black;

  // New Design Colors for Light/Dark Mode
  static const Color primaryApp = Color(0xFF800000); // Brand maroon color
  static const Color secondaryApp = Color(0xFF4F46E5);

  // Light Mode Colors
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF111827);
  static const Color textLightSub = Color(0xFF4B5563);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark Mode Colors
  static const Color bgDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1F2937);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textDarkSub = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);

  // Status indicators
  static const Color green = Color(0xFF10B981);
  static const Color softGreen = Color(0xFFD1FAE5);
  static const Color textGreen = Color(0xFF065F46);

  static const Color orange = Color(0xFFF59E0B);
  static const Color softOrange = Color(0xFFFEF3C7);
  static const Color textOrange = Color(0xFF92400E);
}

