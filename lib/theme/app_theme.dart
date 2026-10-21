import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF5F6F7);
  static const blue = Color(0xFF1F41BB);
  static const blueTint = Color(0xFFEBF0FF);
  static const text = Color(0xFF24374D);
  static const heading = Color(0xFF193878);
}

ThemeData buildAppTheme({String? fontFamily}) => ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.heading),
        headlineMedium: TextStyle(color: AppColors.heading),
        headlineSmall: TextStyle(color: AppColors.heading),
        titleLarge: TextStyle(color: AppColors.heading),
        titleMedium: TextStyle(color: AppColors.heading),
        titleSmall: TextStyle(color: AppColors.heading),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.blue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.blueTint,
        onPrimaryContainer: AppColors.blue,
        secondary: AppColors.blue,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.blueTint,
        onSecondaryContainer: AppColors.blue,
        tertiary: AppColors.blue,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.blueTint,
        onTertiaryContainer: AppColors.blue,
        surface: Colors.white,
        surfaceDim: AppColors.background,
        surfaceBright: Colors.white,
        onSurface: AppColors.text,
        onSurfaceVariant: Color(0xFF71809E),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: AppColors.background,
        surfaceContainerHighest: AppColors.background,
        outline: Color(0xFFD8DFEB),
        outlineVariant: Color(0xFFE8EDF5),
        surfaceTint: Colors.transparent,
        inverseSurface: AppColors.text,
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFFDCE6FF),
      ),
      cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white, surfaceTintColor: Colors.transparent),
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.heading,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
