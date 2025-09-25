import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarOptionalSection extends ConsumerWidget {
  final int pageNumber;
  final int totalHalaman;
  final VoidCallback onPreviewPressed; // <-- 1. Tambahkan properti

  const GambarOptionalSection({
    super.key,
    required this.pageNumber,
    required this.totalHalaman,
    required this.onPreviewPressed, // <-- 2. Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(gambarOptionalOptionsProvider);
    final selectedId = ref.watch(gambarOptionalIdProvider);
    final isSelected = selectedId != null;

    return Row(
      children: [
        const SizedBox(width: 150, child: Text('Gambar Optional:')),
        Expanded(
          child: options.when(
            data: (items) => DropdownButtonFormField<int>(
              value: selectedId,
              decoration: const InputDecoration(
                hintText: 'Pilih Gambar Optional',
                border: OutlineInputBorder(),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e.id as int,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  ref.read(gambarOptionalIdProvider.notifier).state = value,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Error'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            child: Center(child: Text('$pageNumber/$totalHalaman')),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 170,
          child: ElevatedButton(
            // <-- 3. Gunakan fungsi yang diterima
            onPressed: isSelected ? onPreviewPressed : null,
            child: const Text('Preview Gambar'),
          ),
        ),
      ],
    );
  }
}
