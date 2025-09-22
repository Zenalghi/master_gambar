// File: lib/elements/home/widgets/transaksi_history_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart'; // 1. Import package baru
import '../../../data/models/transaksi.dart';
import '../providers/transaksi_providers.dart';

// 2. Ubah menjadi ConsumerStatefulWidget
class TransaksiHistoryTable extends ConsumerStatefulWidget {
  const TransaksiHistoryTable({super.key});

  @override
  ConsumerState<TransaksiHistoryTable> createState() =>
      _TransaksiHistoryTableState();
}

class _TransaksiHistoryTableState extends ConsumerState<TransaksiHistoryTable> {
  // 3. Buat state untuk sorting
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(transaksiHistoryProvider);
    final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return history.when(
      data: (transaksiList) {
        // --- LOGIKA SORTING ---
        // Buat salinan list agar bisa di-sort tanpa mengubah state asli
        final sortedList = List<Transaksi>.from(transaksiList);
        sortedList.sort((a, b) {
          int result = 0;
          // Tentukan cara membandingkan berdasarkan kolom yang dipilih
          switch (_sortColumnIndex) {
            case 0:
              result = a.id.compareTo(b.id);
              break;
            case 1:
              result = a.customer.namaPt.compareTo(b.customer.namaPt);
              break;
            case 2:
              result = a.aTypeEngine.typeEngine.compareTo(
                b.aTypeEngine.typeEngine,
              );
              break;
            // ... tambahkan case untuk semua kolom yang ingin di-sort
            case 7:
              result = a.user.name.compareTo(b.user.name);
              break;
            case 8:
              result = a.createdAt.compareTo(b.createdAt);
              break;
          }
          return _sortAscending ? result : -result;
        });
        // --- AKHIR LOGIKA SORTING ---

        // 4. Ganti DataTable menjadi DataTable2
        return DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth:
              1600, // Beri lebar minimum, akan otomatis scrollable jika lebih kecil
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns:
              _createColumns(), // Gunakan helper function untuk membuat kolom
          rows: sortedList.map((trx) {
            return DataRow(
              cells: [
                // 5. Ganti Text menjadi SelectableText
                DataCell(SelectableText(trx.id)),
                DataCell(SelectableText(trx.customer.namaPt)),
                DataCell(SelectableText(trx.aTypeEngine.typeEngine)),
                DataCell(SelectableText(trx.bMerk.merk)),
                DataCell(SelectableText(trx.cTypeChassis.typeChassis)),
                DataCell(SelectableText(trx.dJenisKendaraan.jenisKendaraan)),
                DataCell(SelectableText(trx.fPengajuan.jenisPengajuan)),
                DataCell(SelectableText(trx.user.name)),
                DataCell(
                  SelectableText(dateFormat.format(trx.createdAt.toLocal())),
                ),
                DataCell(
                  SelectableText(dateFormat.format(trx.updatedAt.toLocal())),
                ),
                // SESUDAHNYA
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Logika untuk edit nanti di sini
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.open_in_new),
                        tooltip: 'Open',
                        onPressed: () {
                          // Logika untuk open nanti di sini
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Gagal memuat histori: $err')),
    );
  }

  // Helper function untuk membuat kolom dengan logic onSort
  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(
        label: Text('ID Transaksi'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(label: Text('Customer'), size: ColumnSize.L, onSort: _onSort),
      DataColumn2(
        label: Text('Type\nEngine'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: Text('Merk'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {},
      ), // Contoh kolom tanpa sort
      DataColumn2(
        label: Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {},
      ),
      DataColumn2(
        label: Text('Jenis\nKendaraan'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {},
      ),
      DataColumn2(
        label: Text('Jenis\nPengajuan'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {},
      ),
      DataColumn2(label: Text('User'), size: ColumnSize.M, onSort: _onSort),
      DataColumn2(
        label: Text('Created At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: Text('Updated At'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {},
      ),
      DataColumn2(label: Text('Option'), size: ColumnSize.S),
    ];
  }

  // Fungsi yang akan dipanggil saat header kolom ditekan
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
