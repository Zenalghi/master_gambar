//lib\app\theme\app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color shadow = Colors.black;
}

ThemeData createAppTheme({required bool darkMode}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: darkMode ? Brightness.dark : Brightness.light,
    background: darkMode ? AppColors.backgroundDark : AppColors.background,
  );

  return ThemeData(
    visualDensity: VisualDensity.compact,
    colorScheme: colorScheme,
    fontFamily: 'Poppins',
    brightness: darkMode ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: colorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 12.0),
      bodySmall: TextStyle(fontSize: 9.0),
      titleMedium: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: darkMode ? 2 : 4,
      shadowColor: darkMode
          ? Colors.transparent
          : AppColors.shadow.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: TextStyle(
        fontSize: 13,
        fontFamily: 'Poppins',
        color: colorScheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      filled: true,
      fillColor: darkMode ? AppColors.surfaceDark : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      columnSpacing: 0,
      horizontalMargin: 8,
      headingRowHeight: 35,
      dataRowMinHeight: 30,
      dataRowMaxHeight: 30,
      dividerThickness: 1,
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        fontSize: 12,
      ),
      dataTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 11),
    ),
    dividerColor: darkMode
        ? const Color.fromRGBO(255, 255, 255, 0.15)
        : const Color.fromRGBO(0, 0, 0, 0.12),
  );
}

class AppTextStyles {
  static TextStyle dynamicSize(String text, {double defaultSize = 12}) {
    double fontSize = defaultSize;

    if (text.length > 45) {
      fontSize = 10;
    } else if (text.length > 15) {
      fontSize = 11;
    }

    return TextStyle(fontSize: fontSize, fontFamily: 'Poppins');
  }
}
