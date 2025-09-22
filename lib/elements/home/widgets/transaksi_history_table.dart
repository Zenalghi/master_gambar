import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../data/models/transaksi.dart';
import '../providers/transaksi_providers.dart';

// 1. BUAT CLASS DATA SOURCE DI SINI
class TransaksiDataSource extends DataTableSource {
  final List<Transaksi> transaksiList;
  final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  TransaksiDataSource(this.transaksiList);

  @override
  DataRow? getRow(int index) {
    if (index >= transaksiList.length) {
      return null;
    }
    final trx = transaksiList[index];

    return DataRow(
      key: ValueKey(trx.id),
      cells: [
        DataCell(SelectableText(trx.id)),
        DataCell(SelectableText(trx.customer.namaPt)),
        DataCell(SelectableText(trx.aTypeEngine.typeEngine)),
        DataCell(SelectableText(trx.bMerk.merk)),
        DataCell(SelectableText(trx.cTypeChassis.typeChassis)),
        DataCell(
          Container(
            width: 100,
            child: SelectableText(
              trx.dJenisKendaraan.jenisKendaraan,
              maxLines: 2,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 80,
            child: SelectableText(trx.fPengajuan.jenisPengajuan, maxLines: 2),
          ),
        ),
        DataCell(SelectableText(trx.user.name)),
        DataCell(SelectableText(dateFormat.format(trx.createdAt.toLocal()))),
        DataCell(SelectableText(dateFormat.format(trx.updatedAt.toLocal()))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.orange.shade700),
                tooltip: 'Edit',
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.blue.shade700),
                tooltip: 'Open',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transaksiList.length;

  @override
  int get selectedRowCount => 0;
}

// WIDGET UTAMA (SEKARANG MENGGUNAKAN PaginatedDataTable2)
class TransaksiHistoryTable extends ConsumerStatefulWidget {
  const TransaksiHistoryTable({super.key});

  @override
  ConsumerState<TransaksiHistoryTable> createState() =>
      _TransaksiHistoryTableState();
}

class _TransaksiHistoryTableState extends ConsumerState<TransaksiHistoryTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(transaksiHistoryProvider);
    // Tonton provider rowsPerPage
    final rowsPerPage = ref.watch(rowsPerPageProvider);

    return history.when(
      data: (transaksiList) {
        final sortedList = List<Transaksi>.from(transaksiList);
        // ... (logika sorting tidak berubah) ...
        sortedList.sort((a, b) {
          int result = 0;
          // Tentukan cara membandingkan berdasarkan kolom yang dipilih
          switch (_sortColumnIndex) {
            case 0: // ID Transaksi
              result = a.id.compareTo(b.id);
              break;
            case 1: // Customer
              result = a.customer.namaPt.compareTo(b.customer.namaPt);
              break;
            case 2: // Type Engine
              result = a.aTypeEngine.typeEngine.compareTo(
                b.aTypeEngine.typeEngine,
              );
              break;
            case 7: // User
              result = a.user.name.compareTo(b.user.name);
              break;
            case 8: // Created At
              result = a.createdAt.compareTo(b.createdAt);
              break;
            // Anda bisa tambahkan case lain untuk kolom lain jika diperlukan
            case 9: // Updated At
              result = a.updatedAt.compareTo(b.updatedAt);
              break;
          }
          // Terapkan arah sorting (ascending/descending)
          return _sortAscending ? result : -result;
        });
        // 2. BUAT INSTANCE DARI DATA SOURCE
        final dataSource = TransaksiDataSource(sortedList);

        // 3. GANTI DataTable2 MENJADI PaginatedDataTable2
        return PaginatedDataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1600,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,

          // --- KONTROL PAGINASI DAN ENTRIES ---
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: const [10, 25, 50],
          onRowsPerPageChanged: (value) {
            // Update state saat user memilih jumlah baris baru
            if (value != null) {
              ref.read(rowsPerPageProvider.notifier).state = value;
            }
          },

          // ------------------------------------
          columns: _createColumns(),
          // Gunakan 'source' bukan 'rows'
          source: dataSource,
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
        onSort: _onSort,
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
