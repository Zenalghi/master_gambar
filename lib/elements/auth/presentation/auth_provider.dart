import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/core/providers.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repository/auth_repository.dart';

// State Notifier untuk proses login
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });

// Provider untuk mengambil info paket (termasuk versi)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.data(null));

  // Fungsi login sekarang menerima 'ref' untuk diteruskan ke repository
  Future<void> login(String username, String password, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      // Teruskan 'ref' ke repository
      await _authRepository.login(username, password, ref);
      state = const AsyncValue.data(null); // Sukses
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current); // Error
    }
  }
}
