import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import '../../../../app/core/notifiers/refresh_notifier.dart';
import '../../../../data/models/option_item.dart';

class GambarHeaderInfo extends ConsumerWidget {
  final Transaksi transaksi;

  const GambarHeaderInfo({super.key, required this.transaksi});
  void _resetAndRefresh(BuildContext context, WidgetRef ref) {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.invalidate(gambarOptionalSelectionProvider);
    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
    ref.watch(kelistrikanInfoProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memuat ulang data pilihan...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoField('No. ID', transaksi.id),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Type Engine',
                  transaksi.aTypeEngine.typeEngine,
                ),
                const SizedBox(width: 16),
                _buildInfoField('Merk', transaksi.bMerk.merk),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Type Chassis',
                  transaksi.cTypeChassis.typeChassis,
                ),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Jenis Kendaraan',
                  transaksi.dJenisKendaraan.jenisKendaraan,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInfoField('Customer', transaksi.customer.namaPt),

                const SizedBox(width: 16),
                _buildInfoField(
                  'Jenis Pengajuan',
                  transaksi.fPengajuan.jenisPengajuan,
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildPemeriksaDropdown(ref)),

                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      Expanded(child: _buildJumlahGambarDropdown(ref)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Muat Ulang Pilihan',
                        onPressed: () => _resetAndRefresh(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildJumlahGambarDropdown(WidgetRef ref) {
    final selectedJumlah = ref.watch(jumlahGambarProvider);

    final options = [1, 2, 3, 4];

    return DropdownButtonFormField<int>(
      value: selectedJumlah,
      itemHeight: 30,
      decoration: const InputDecoration(
        labelStyle: TextStyle(fontSize: 13),
        labelText: 'Jumlah Gambar',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
      items: options
          .map(
            (e) => DropdownMenuItem<int>(value: e, child: Text(e.toString())),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(jumlahGambarProvider.notifier).state = value;
        }
      },
    );
  }
}

Widget _buildPemeriksaDropdown(WidgetRef ref) {
  final pemeriksaOptionsAsync = ref.watch(pemeriksaOptionsProvider);
  final selectedId = ref.watch(pemeriksaIdProvider);
  ref.listen<AsyncValue<List<OptionItem>>>(pemeriksaOptionsProvider, (
    previous,
    next,
  ) {
    if (next is AsyncData && !(previous is AsyncData)) {
      final options = next.value;
      if (options != null &&
          options.isNotEmpty &&
          ref.read(pemeriksaIdProvider) == null) {
        ref.read(pemeriksaIdProvider.notifier).state = options.first.id as int?;
      }
    }
  });

  return pemeriksaOptionsAsync.when(
    data: (items) {
      if (items.isNotEmpty && selectedId == null) {
        Future.microtask(() {
          if (ref.read(pemeriksaIdProvider) == null) {
            ref.read(pemeriksaIdProvider.notifier).state =
                items.first.id as int?;
          }
        });
      }

      return DropdownButtonFormField<int>(
        value: selectedId,
        itemHeight: 30,
        style: const TextStyle(fontSize: 13, color: Colors.black),
        hint: const Text('Pemeriksa', style: TextStyle(fontSize: 13)),
        decoration: const InputDecoration(
          labelStyle: TextStyle(fontSize: 13),
          labelText: 'Pemeriksa',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<int>(
                value: e.id as int,
                child: Text(e.name, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(pemeriksaIdProvider.notifier).state = value;
        },
        validator: (value) => value == null ? 'Wajib dipilih' : null,
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => const Tooltip(
      message: 'Error memuat pemeriksa',
      child: Icon(Icons.error),
    ),
  );
}
