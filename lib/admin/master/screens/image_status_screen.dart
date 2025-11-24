import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../widgets/image_status_table.dart';

// 1. Ubah menjadi ConsumerStatefulWidget
class ImageStatusScreen extends ConsumerStatefulWidget {
  const ImageStatusScreen({super.key});

  @override
  ConsumerState<ImageStatusScreen> createState() => _ImageStatusScreenState();
}

class _ImageStatusScreenState extends ConsumerState<ImageStatusScreen> {
  @override
  void initState() {
    super.initState();
    // 2. Reset filter & paksa refresh saat halaman dibuka
    Future.microtask(() {
      ref.invalidate(imageStatusFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: const InputDecoration(
                    labelText: 'Search (Type Engine, Merk, Varian, dll...)',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Update search state
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
                  // Trigger refresh manual
                  ref.invalidate(imageStatusFilterProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Widget Tabel
          const Expanded(child: ImageStatusTable()),
        ],
      ),
    );
  }
}
