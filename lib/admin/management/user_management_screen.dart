import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'package:master_gambar/admin/management/widgets/user/add_user_form.dart';
import 'package:master_gambar/admin/management/widgets/user/user_data_table.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manajemen User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search User...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // --- PERUBAHAN DI SINI ---
                  onChanged: (value) => ref
                      .read(userNotifierProvider.notifier)
                      .onSearchChanged(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AddUserForm(),
          const SizedBox(height: 24),
          const Expanded(child: UserDataTable()),
        ],
      ),
    );
  }
}
