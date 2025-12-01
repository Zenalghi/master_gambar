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
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              Text(
                'Manajemen User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search User...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => ref
                      .read(userNotifierProvider.notifier)
                      .onSearchChanged(value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat Ulang Data',
                onPressed: () {
                  ref.read(userInvalidator.notifier).state++;
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          const AddUserForm(),
          const SizedBox(height: 1),
          const Expanded(child: UserDataTable()),
        ],
      ),
    );
  }
}
