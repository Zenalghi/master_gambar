import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarOptionalSection extends ConsumerWidget {
  final int basePageNumber;
  final int totalHalaman;
  final Function(int) onPreviewPressed;

  const GambarOptionalSection({
    super.key,
    required this.basePageNumber,
    required this.totalHalaman,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jumlah = ref.watch(jumlahGambarOptionalProvider);

    // Listener untuk mengubah ukuran state list saat dropdown jumlah berubah
    ref.listen<int>(jumlahGambarOptionalProvider, (prev, next) {
      ref.read(gambarOptionalSelectionProvider.notifier).resize(next);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJumlahDropdown(ref),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jumlah,
          itemBuilder: (context, index) {
            return _GambarOptionalRow(
              index: index,
              pageNumber: basePageNumber + index,
              totalHalaman: totalHalaman,
              onPreviewPressed: () =>
                  onPreviewPressed(basePageNumber + index - 1),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }

  Widget _buildJumlahDropdown(WidgetRef ref) {
    return Row(
      children: [
        const SizedBox(width: 150, child: Text('Jumlah Gambar Optional:')),
        SizedBox(
          width: 100,
          child: DropdownButtonFormField<int>(
            value: ref.watch(jumlahGambarOptionalProvider),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [1, 2, 3, 4, 5]
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.toString())),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(jumlahGambarOptionalProvider.notifier).state = value;
              }
            },
          ),
        ),
      ],
    );
  }
}

// Widget privat untuk satu baris
class _GambarOptionalRow extends ConsumerWidget {
  final int index;
  final int pageNumber;
  final int totalHalaman;
  final VoidCallback onPreviewPressed;

  const _GambarOptionalRow({
    required this.index,
    required this.pageNumber,
    required this.totalHalaman,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(gambarOptionalOptionsProvider);
    final selection = ref.watch(gambarOptionalSelectionProvider)[index];
    final isSelected = selection.gambarOptionalId != null;
    return Row(
      children: [
        const SizedBox(width: 150, child: Text('Gambar Optional:')),
        Expanded(
          child: options.when(
            data: (items) => DropdownButtonFormField<int>(
              value: selection.gambarOptionalId,
              decoration: InputDecoration(
                hintText: 'Pilih Gambar Optional ${index + 1}',
                border: const OutlineInputBorder(),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e.id as int,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => ref
                  .read(gambarOptionalSelectionProvider.notifier)
                  .updateSelection(index, gambarOptionalId: value),
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
