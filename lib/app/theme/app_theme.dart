//lib\app\theme\app_theme.dart
import 'package:flutter/material.dart';

// Palet warna dasar agar mudah diubah nanti
class AppColors {
  static const Color primary = Color(0xFF0D47A1); // Biru tua
  static const Color background = Color(0xFFF5F5F5); // Abu-abu muda
  static const Color card = Colors.white;
  static const Color shadow = Colors.black;
}

// Fungsi utama untuk membuat ThemeData
ThemeData createAppTheme() {
  return ThemeData(
    // Atur skema warna utama
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),

    // Atur font default untuk seluruh aplikasi
    fontFamily: 'Poppins',

    // Atur tema untuk Scaffold (latar belakang halaman)
    scaffoldBackgroundColor: AppColors.background,

    // TEMA KARTU (INI KUNCI UNTUK BOX DENGAN SHADOW)
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 8.0, // Mengatur seberapa tebal shadow
      shadowColor: AppColors.shadow.withOpacity(
        0.9,
      ), // Warna shadow dengan transparansi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Membuat sudut melengkung
      ),
    ),

    // TEMA UNTUK KOLOM INPUT (USERNAME & PASSWORD)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none, // Hilangkan border, kita andalkan shadow
      ),
      filled: true,
      fillColor: AppColors.background, // Sedikit abu-abu agar kontras
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
    ),

    // TEMA UNTUK TOMBOL
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Warna teks tombol
        backgroundColor: AppColors.primary, // Warna latar tombol
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    dataTableTheme: DataTableThemeData(
      // 1. columnSpacing: Mengatur jarak antar kolom.
      // Defaultnya besar (56.0). Ubah ke 10-15 agar "garis batas" lebih rapat ke teks.
      columnSpacing: 10.0,

      // 2. horizontalMargin: Jarak dari pinggir tabel paling kiri & kanan.
      horizontalMargin: 10.0,

      // 3. headingRowHeight: Tinggi baris judul (opsional, biar tidak terlalu tinggi)
      headingRowHeight: 45,

      // 4. dataRowMin/MaxHeight: Tinggi baris data
      dataRowMinHeight: 40,
      dataRowMaxHeight: 52,
    ),
  );
}

// === TAMBAHKAN CLASS INI ===
class AppTextStyles {
  /// Mengembalikan TextStyle dengan ukuran font dinamis berdasarkan panjang teks
  static TextStyle dynamicSize(String text, {double defaultSize = 13}) {
    double fontSize = defaultSize;

    if (text.length > 45) {
      fontSize = 10; // Jika lebih dari 26 huruf
    } else if (text.length > 15) {
      fontSize = 13;
    }
    // Jika <= 15, tetap pakai defaultSize (13)

    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Poppins', // Pastikan font tetap sama
      // Anda bisa tambah properti lain jika mau, misal color: Colors.black87
    );
  }
}
