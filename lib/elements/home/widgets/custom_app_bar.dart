// File: lib/elements/home/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../app/core/providers.dart';
// import 'global_refresh_button.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userName = ref.watch(userNameProvider);
    final isDarkMode = ref.watch(darkModeProvider);

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      title: TabBar(
        indicatorPadding: const EdgeInsets.only(bottom: 12),
        isScrollable: true,
        labelColor: Theme.of(context).colorScheme.onSurface,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: [
          const Tab(text: 'WORK AREA'),
          if (authService.canViewAdminTabs()) ...[
            const Tab(text: 'MASTER'),
            const Tab(text: 'CONFIGURATION'),
          ],
        ],
      ),
      actions: [
        if (userName != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                userName,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: () async {
            ref.read(darkModeProvider.notifier).state = !isDarkMode;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', !isDarkMode);
          },
        ),
        VerticalDivider(
          thickness: 1,
          width: 1,
          indent: 12,
          endIndent: 12,
          color: Theme.of(context).dividerColor,
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Logout',
          onPressed: () async {
            await ref.read(authRepositoryProvider).logout(ref);

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
  Size get preferredSize => const Size.fromHeight(40);
}
