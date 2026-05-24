import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'package:master_gambar/admin/management/widgets/user/add_user_form.dart';
import 'package:master_gambar/admin/management/widgets/user/user_data_table.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshUsers() {
    _searchController.clear();
    ref.read(userSearchQueryProvider.notifier).state = '';
    ref.read(userInvalidator.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(fontSize: 14),
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
                onPressed: _refreshUsers,
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
