//lib\app\core\notifiers\refresh_notifier.dart
import 'package:flutter_riverpod/legacy.dart';

// 1. Notifier itu sendiri, isinya hanya sebuah counter
class RefreshNotifier extends StateNotifier<int> {
  RefreshNotifier() : super(0);

  void refresh() {
    state++; // Setiap kali refresh, kita tingkatkan angkanya
  }
}

// 2. Provider global untuk mengakses notifier di seluruh aplikasi
final refreshNotifierProvider = StateNotifierProvider<RefreshNotifier, int>(
  (ref) => RefreshNotifier(),
);
