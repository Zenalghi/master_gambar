//lib\elements\home\providers\page_state_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/data/models/transaksi.dart';

// Class untuk menampung state halaman aktif
class PageState {
  final int pageIndex;
  final Transaksi? data; // Data opsional, hanya untuk halaman yg butuh data

  PageState({required this.pageIndex, this.data});
}

// Provider global untuk menyimpan PageState saat ini
final pageStateProvider = StateProvider<PageState>(
  // Halaman default saat aplikasi pertama kali dibuka
  (ref) => PageState(pageIndex: 0),
);
