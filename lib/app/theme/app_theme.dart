//lib\app\theme\app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1);
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Colors.white;
  static const Color shadow = Colors.black;
}

ThemeData createAppTheme() {
  return ThemeData(
    // --- PERBAIKAN 3: Visual Density Compact ---
    // Ini AJAIB. Ini akan membuang padding berlebih di seluruh aplikasi.
    // Tombol jadi lebih ramping, jarak antar elemen lebih rapat.
    visualDensity: VisualDensity.compact,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.background,

    // --- PERBAIKAN 4: Perkecil Ukuran Font Default ---
    // Kita definisikan ulang text theme agar base-nya lebih kecil (12-14px)
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 13.0), // Default text
      bodySmall: TextStyle(fontSize: 12.0), // Text kecil
      titleMedium: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
      ), // Subjudul
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 4.0, // Kurangi shadow sedikit agar tidak terlalu berat
      shadowColor: AppColors.shadow.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Radius dikurangi sedikit
      ),
      // Kurangi margin card agar tidak makan tempat
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      isDense: true, // PENTING: Memadatkan tinggi kolom input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8.0,
        ), // Radius lebih kotak dikit hemat tempat
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor:
          Colors.white, // Ubah ke putih biar bersih, atau tetap background
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0, // Kurangi padding kiri kanan
        vertical: 10.0, // Kurangi padding atas bawah (sebelumnya 14)
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        // Kurangi padding tombol
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: const TextStyle(
          fontSize: 14, // Kecilkan font tombol (sebelumnya 16)
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // --- PERBAIKAN 5: Tabel Lebih Padat ---
    dataTableTheme: DataTableThemeData(
      // 1. Jarak antar kolom sangat dekat (default 56, kita buat 0 atau kecil)
      // Kita buat 0 agar garis vertikal nanti terlihat menyatu
      columnSpacing: 0,

      // 2. Jarak dari pinggir tabel (kiri/kanan)
      horizontalMargin: 8,

      // 3. Tinggi Header (Pendek)
      headingRowHeight: 35,

      // 4. Tinggi Baris Data (Pendek & Tetap)
      dataRowMinHeight: 30,
      dataRowMaxHeight: 30, // Memaksa tinggi baris fix 30px (mirip Excel)
      // 5. Garis Horizontal
      dividerThickness: 1, // Garis pemisah antar baris terlihat jelas
      // 6. Style Teks (Lebih Kecil)
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 12, // Font header kecil
      ),
      dataTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 11, // Font data kecil (mirip Excel 11pt)
      ),
    ),
  );
}

// Class AppTextStyles tetap bisa dipakai, tapi dengan base size lebih kecil
class AppTextStyles {
  static TextStyle dynamicSize(String text, {double defaultSize = 12}) {
    // Default turun ke 12
    double fontSize = defaultSize;

    if (text.length > 45) {
      fontSize = 10;
    } else if (text.length > 15) {
      fontSize = 11; // Sedikit lebih kecil
    }

    return TextStyle(fontSize: fontSize, fontFamily: 'Poppins');
  }
}
