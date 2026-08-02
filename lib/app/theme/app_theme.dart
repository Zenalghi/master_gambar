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
    surface: darkMode ? AppColors.backgroundDark : AppColors.background,
  );

  return ThemeData(
    visualDensity: VisualDensity.compact,
    colorScheme: colorScheme,
    fontFamily: 'Poppins',
    brightness: darkMode ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: colorScheme.surface,
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
          : AppColors.shadow.withAlpha(128),
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

class SkrbActionColors {
  final bool isDark;
  SkrbActionColors(Brightness brightness)
    : isDark = brightness == Brightness.dark;

  // 1. Hide / Unhide Icon
  Color get hideIcon =>
      isDark ? const Color.fromARGB(255, 255, 94, 0) : const Color(0xFFFBBF24);
  Color get unhideIcon =>
      isDark ? const Color(0xFFFBBF24) : const Color.fromARGB(255, 255, 94, 0);

  // 2. Pilih File Button (Upload Baru)
  Color get pilihFileBg =>
      isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
  Color get pilihFileFg => isDark ? const Color(0xFF064E3B) : Colors.white;

  // 3. Ganti File Button (Replace File)
  Color get gantiFileBg =>
      isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488);
  Color get gantiFileFg => isDark ? const Color(0xFF042F2E) : Colors.white;

  // Disabled Upload Button State
  Color get uploadDisabledBg =>
      isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  Color get uploadDisabledFg =>
      isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  // 4. Preview Dokumen (Live / Fase 1 & 3 Mode Edit)
  Color get previewLiveBg =>
      isDark ? const Color(0xFF042F2E) : const Color(0xFFE6FFFA);
  Color get previewLiveFg =>
      isDark ? const Color(0xFF5EEAD4) : const Color(0xFF006C67);
  Color get previewLiveBorder =>
      isDark ? const Color(0xFF134E4A) : const Color(0xFF4FD1C5);

  // 5. Preview Dokumen (History / Fase 2 Terkunci)
  Color get previewHistoryBg =>
      isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF);
  Color get previewHistoryFg =>
      isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
  Color get previewHistoryBorder =>
      isDark ? const Color(0xFF1E40AF) : const Color(0xFF93C5FD);
}

extension SkrbActionThemeExtension on BuildContext {
  SkrbActionColors get skrbActions =>
      SkrbActionColors(Theme.of(this).brightness);
}
