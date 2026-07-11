import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData laserTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff01ff92),
    primary: const Color(0xff01ff92),
    brightness: Brightness.dark,
  ),

    textTheme: TextTheme(
        displayLarge: GoogleFonts.aldrich(
          fontSize: 57,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.aldrich(
          fontSize: 45,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: GoogleFonts.aldrich(
          fontSize: 36,
          fontWeight: FontWeight.w500,
        ),

        titleLarge: GoogleFonts.openSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        bodyLarge: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),

        labelLarge: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.openSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
    ),

  appBarTheme: AppBarTheme(
    titleTextStyle: GoogleFonts.aldrich(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    elevation: 4,
    centerTitle: false,
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff01ff92), width: 2.0),
    ),
    floatingLabelStyle: TextStyle(color: Colors.white),
    hintStyle: TextStyle(color: Colors.white54),
  ),

  sliderTheme: SliderThemeData(
    activeTrackColor: const Color(0xFF74F99C),
    thumbColor: const Color(0xFFFFFFFF),
    inactiveTrackColor: Colors.grey.shade800,
    valueIndicatorColor: Colors.white
  ),

  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF74F99C);
      }
      return null;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFFFFFFFF);
      }
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF74F99C).withValues(alpha: 0.5);
      }
      return null;
    }),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0x00FFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey.shade800),
  )
);