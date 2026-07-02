import 'package:flutter/material.dart';
import 'package:Saleh/core/constant/Colorapp.dart';

ThemeData themeLight = ThemeData(
  brightness: Brightness.light,
  fontFamily: "Cairo",
  scaffoldBackgroundColor: AppColor.bgLight,
  cardColor: AppColor.cardLight,
  dividerColor: AppColor.borderLight,
  primaryColor: AppColor.primaryApp,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColor.textLight,
      fontWeight: FontWeight.bold,
      fontFamily: "Cairo",
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: AppColor.primaryApp),
    backgroundColor: AppColor.cardLight,
    elevation: 1,
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: AppColor.cardLight,
    elevation: 8,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: AppColor.textLight,
      fontFamily: "Cairo",
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: AppColor.textLight,
      fontFamily: "Cairo",
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: AppColor.textLight,
      fontFamily: "Cairo",
    ),
    bodyLarge: TextStyle(
      height: 1.6,
      color: AppColor.textLight,
      fontWeight: FontWeight.bold,
      fontSize: 15,
      fontFamily: "Cairo",
    ),
    bodyMedium: TextStyle(
      height: 1.6,
      color: AppColor.textLightSub,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      fontFamily: "Cairo",
    ),
    bodySmall: TextStyle(
      height: 1.6,
      color: AppColor.grey,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      fontFamily: "Cairo",
    ),
  ),
);

ThemeData themeDark = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Cairo",
  scaffoldBackgroundColor: AppColor.bgDark,
  cardColor: AppColor.cardDark,
  dividerColor: AppColor.borderDark,
  primaryColor: AppColor.primaryApp,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColor.textDark,
      fontWeight: FontWeight.bold,
      fontFamily: "Cairo",
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: AppColor.textDark),
    backgroundColor: AppColor.cardDark,
    elevation: 1,
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: AppColor.cardDark,
    elevation: 8,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: AppColor.textDark,
      fontFamily: "Cairo",
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: AppColor.textDark,
      fontFamily: "Cairo",
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: AppColor.textDark,
      fontFamily: "Cairo",
    ),
    bodyLarge: TextStyle(
      height: 1.6,
      color: AppColor.textDark,
      fontWeight: FontWeight.bold,
      fontSize: 15,
      fontFamily: "Cairo",
    ),
    bodyMedium: TextStyle(
      height: 1.6,
      color: AppColor.textDarkSub,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      fontFamily: "Cairo",
    ),
    bodySmall: TextStyle(
      height: 1.6,
      color: AppColor.grey,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      fontFamily: "Cairo",
    ),
  ),
);

