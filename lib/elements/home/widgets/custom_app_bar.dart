// File: lib/elements/home/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/providers.dart';
import '../../auth/presentation/screens/login_screen.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Baca role langsung dari StateProvider.
    final userRole = ref.watch(userRoleProvider);

    return AppBar(
      automaticallyImplyLeading: false, 
      title: TabBar(
        isScrollable: true,
        tabs: [
          const Tab(text: 'WORK AREA'),
          if (userRole == 'admin') ...[
            const Tab(text: 'MASTER'),
            const Tab(text: 'CONFIGURATION'),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            // Logout sekarang membutuhkan 'ref' untuk update StateProvider
            await ref.read(authRepositoryProvider).logout(ref);
            
            // Navigasi setelah logout
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}