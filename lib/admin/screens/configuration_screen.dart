//lib\admin\screens\configuration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/widgets/configuration_sidebar.dart';
import '../management/customer_management_screen.dart';
import '../management/document_customer_screen.dart';
import '../management/user_management_screen.dart';
import '../management/providers/customer_providers.dart';

class ConfigurationScreen extends ConsumerWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(configurationTabIndexProvider);

    final List<Widget> pages = const [
      CustomerManagementScreen(),
      DocumentCustomerScreen(),
      UserManagementScreen(),
    ];

    return Row(
      children: [
        // Sidebar di sebelah kiri
        ConfigurationSidebar(
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            ref.read(configurationTabIndexProvider.notifier).state = index;
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Konten di sebelah kanan, akan berubah sesuai pilihan sidebar
        Expanded(child: pages[selectedIndex]),
      ],
    );
  }
}
