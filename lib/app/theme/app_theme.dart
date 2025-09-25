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
  );
}
