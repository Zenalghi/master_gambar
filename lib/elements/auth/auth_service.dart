// File: lib/elements/auth/auth_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/providers.dart';

class AuthService {
  final Ref _ref;

  // AuthService "mendengarkan" perubahan pada userRoleProvider
  String? get _userRole => _ref.watch(userRoleProvider);

  AuthService(this._ref);

  // --- Definisikan semua hak akses di sini ---

  // Hak akses untuk melihat tab admin (MASTER, CONFIGURATION)
  bool canViewAdminTabs() {
    return _userRole == 'admin';
  }

  // Hak akses untuk mengelola user dan customer (biasanya hanya admin)
  bool canManageUsersAndCustomers() {
    return _userRole == 'admin';
  }

  // Hak akses untuk input transaksi (drafter bisa, mungkin admin juga)
  bool canInputTransaksi() {
    return _userRole == 'admin' || _userRole == 'drafter';
  }

  // Hak akses untuk memeriksa/memproses transaksi (pemeriksa dan admin)
  bool canProcessTransaksi() {
    return _userRole == 'admin' || _userRole == 'pemeriksa';
  }

  // Anda bisa tambahkan hak akses lainnya di sini...
  // bool canUploadMasterImage() { ... }
}
