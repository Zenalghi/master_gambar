import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../widgets/type_engine_table.dart';

class MasterTypeEngineScreen extends ConsumerWidget {
  const MasterTypeEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Type Engine',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () => ref.invalidate(typeEngineListProvider),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Nama Type Engine Baru',
                        hintText: 'Contoh: EURO 4',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      try {
                        await ref
                            .read(masterDataRepositoryProvider)
                            .addTypeEngine(typeEngine: controller.text);
                        controller.clear();
                        ref.invalidate(typeEngineListProvider); // Refresh tabel
                      } on DioException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${e.response?.data['message']}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: TypeEngineTable()),
        ],
      ),
    );
  }
}
