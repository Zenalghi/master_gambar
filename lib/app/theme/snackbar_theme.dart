// File: lib/app/theme/snackbar_theme.dart
import 'package:flutter/material.dart';

/// Kelas konfigurasi tema dan utilitas untuk SnackBar di seluruh aplikasi.
/// Menjamin teks selalu berwarna putih terang dengan kontras tajam pada mode gelap maupun terang,
/// baik saat muncul di atas background biru, hijau, merah, oranye, maupun warna lainnya.
class AppSnackBarTheme {
  /// Membangun konfigurasi SnackBarThemeData global untuk dimasukkan ke ThemeData utama di app_theme.dart.
  /// Setiap SnackBar biasa di aplikasi yang tidak mendefinisikan style teks custom
  /// akan otomatis mewarisi warna teks putih bersih dari tema ini.
  static SnackBarThemeData buildSnackBarTheme({required bool darkMode}) {
    return SnackBarThemeData(
      backgroundColor: darkMode ? const Color(0xFF1E293B) : const Color(0xFF334155),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      actionTextColor: const Color(0xFF60A5FA),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }
}

/// Helper untuk menampilkan SnackBar dengan palet warna konsisten & teks selalu kontras putih.
class AppSnackBar {
  static const TextStyle defaultTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  /// Menampilkan SnackBar dengan warna custom dan teks selalu kontras putih
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: defaultTextStyle),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: behavior,
        margin: margin,
      ),
    );
  }

  /// SnackBar Sukses (Background Hijau Konsisten & Teks Putih Kontras)
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, backgroundColor: const Color(0xFF10B981));
  }

  /// SnackBar Error / Gagal (Background Merah Konsisten & Teks Putih Kontras)
  static void showError(BuildContext context, String message) {
    show(context, message: message, backgroundColor: const Color(0xFFEF4444));
  }

  /// SnackBar Peringatan (Background Oranye Konsisten & Teks Putih Kontras)
  static void showWarning(BuildContext context, String message) {
    show(context, message: message, backgroundColor: const Color(0xFFF59E0B));
  }

  /// SnackBar Info (Background Biru Konsisten & Teks Putih Kontras)
  static void showInfo(BuildContext context, String message) {
    show(context, message: message, backgroundColor: const Color(0xFF3B82F6));
  }
}

/// Extension pada BuildContext agar pemanggilan SnackBar di setiap screen lebih ringkas dan konsisten
extension AppSnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message) => AppSnackBar.showSuccess(this, message);
  void showErrorSnackBar(String message) => AppSnackBar.showError(this, message);
  void showWarningSnackBar(String message) => AppSnackBar.showWarning(this, message);
  void showInfoSnackBar(String message) => AppSnackBar.showInfo(this, message);
}
