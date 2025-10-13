// File: lib/admin/master/screens/image_status_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../widgets/image_status_table.dart';

class ImageStatusScreen extends ConsumerWidget {
  const ImageStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Laporan Status Gambar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search (Type Engine, Merk, Varian, dll...)',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    ref
                        .read(imageStatusFilterProvider.notifier)
                        .update((state) => {...state, 'search': value});
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat Ulang Laporan',
                onPressed: () {
                  // Invalidate provider akan memaksa data source untuk refresh
                  ref.invalidate(imageStatusSourceProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(child: ImageStatusTable()),
        ],
      ),
    );
  }
}
