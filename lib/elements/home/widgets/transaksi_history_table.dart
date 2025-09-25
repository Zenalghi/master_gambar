import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../data/models/transaksi.dart';
import '../providers/page_state_provider.dart';
import '../providers/transaksi_providers.dart';
import 'package:master_gambar/app/core/providers.dart'; // <-- Import provider
import 'package:master_gambar/elements/auth/auth_service.dart';
import 'edit_transaksi_dialog.dart'; // <-- Import dialog yang baru dibuat

// 1. BUAT CLASS DATA SOURCE DI SINI
class TransaksiDataSource extends DataTableSource {
  final List<Transaksi> transaksiList;
  final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');
  final AuthService authService; // <-- Tambah
  final int? currentUserId; // <-- Tambah
  final BuildContext context; // <-- Tambah context untuk dialog
  final WidgetRef ref; // <-- Tambah ref untuk invalidate

  TransaksiDataSource(
    this.transaksiList,
    this.authService,
    this.currentUserId,
    this.context,
    this.ref,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= transaksiList.length) {
      return null;
    }
    final trx = transaksiList[index];
    final bool canEdit =
        authService.canViewAdminTabs() || trx.user.id == currentUserId;

    return DataRow(
      key: ValueKey(trx.id),
      cells: [
        DataCell(SelectableText(trx.id)),
        DataCell(SelectableText(trx.customer.namaPt)),
        DataCell(SelectableText(trx.aTypeEngine.typeEngine)),
        DataCell(SelectableText(trx.bMerk.merk)),
        DataCell(SelectableText(trx.cTypeChassis.typeChassis)),
        DataCell(SelectableText(trx.dJenisKendaraan.jenisKendaraan)),
        DataCell(SelectableText(trx.fPengajuan.jenisPengajuan)),
        DataCell(SelectableText(trx.user.name)),
        DataCell(SelectableText(dateFormat.format(trx.createdAt.toLocal()))),
        DataCell(SelectableText(dateFormat.format(trx.updatedAt.toLocal()))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: canEdit ? Colors.orange.shade700 : Colors.grey,
                ),
                tooltip: canEdit ? 'Edit' : 'Anda tidak punya akses',
                onPressed: canEdit
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => EditTransaksiDialog(transaksi: trx),
                        );
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.blue.shade700),
                tooltip: 'Open',
                onPressed: () {
                  // Update state global, bukan navigasi manual
                  ref.read(pageStateProvider.notifier).state = PageState(
                    pageIndex: 1, // Index untuk InputGambarScreen
                    data: trx, // Kirim data transaksi yang dipilih
                  );
                },
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
  int _sortColumnIndex = 9;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(transaksiHistoryProvider);
    final rowsPerPage = ref.watch(rowsPerPageProvider);
    final searchQuery = ref.watch(globalSearchQueryProvider);
    final customerFilter = ref.watch(customerFilterProvider);
    final typeEngineFilter = ref.watch(typeEngineFilterProvider);
    final merkFilter = ref.watch(merkFilterProvider);
    final typeChassisFilter = ref.watch(typeChassisFilterProvider);
    final jenisKendaraanFilter = ref.watch(jenisKendaraanFilterProvider);
    final jenisPengajuanFilter = ref.watch(jenisPengajuanFilterProvider);
    final userFilter = ref.watch(userFilterProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return history.when(
      data: (transaksiList) {
        final filteredList = transaksiList.where((trx) {
          final query = searchQuery.toLowerCase();
          final globalMatch =
              query.isEmpty ||
              trx.id.toLowerCase().contains(query) ||
              trx.customer.namaPt.toLowerCase().contains(query) ||
              trx.aTypeEngine.typeEngine.toLowerCase().contains(query) ||
              trx.bMerk.merk.toLowerCase().contains(query) ||
              trx.cTypeChassis.typeChassis.toLowerCase().contains(query) ||
              trx.dJenisKendaraan.jenisKendaraan.toLowerCase().contains(
                query,
              ) ||
              trx.fPengajuan.jenisPengajuan.toLowerCase().contains(query) ||
              trx.user.name.toLowerCase().contains(query);

          final customerMatch = trx.customer.namaPt.toLowerCase().contains(
            customerFilter.toLowerCase(),
          );
          final typeEngineMatch = trx.aTypeEngine.typeEngine
              .toLowerCase()
              .contains(typeEngineFilter.toLowerCase());
          // Tambahkan filter lain sesuai kebutuhan
          final merkMatch = trx.bMerk.merk.toLowerCase().contains(
            merkFilter.toLowerCase(),
          );
          final typeChassisMatch = trx.cTypeChassis.typeChassis
              .toLowerCase()
              .contains(typeChassisFilter.toLowerCase());
          final jenisKendaraanMatch = trx.dJenisKendaraan.jenisKendaraan
              .toLowerCase()
              .contains(jenisKendaraanFilter.toLowerCase());
          final userMatch = trx.user.name.toLowerCase().contains(
            userFilter.toLowerCase(),
          );
          final jenisPengajuanMatch = trx.fPengajuan.jenisPengajuan
              .toLowerCase()
              .contains(jenisPengajuanFilter.toLowerCase());

          return globalMatch &&
              customerMatch &&
              typeEngineMatch &&
              merkMatch &&
              typeChassisMatch &&
              jenisKendaraanMatch &&
              jenisPengajuanMatch &&
              userMatch;
        }).toList();

        // LANGKAH 2: Lakukan soring pada 'filteredList' (hasil dari langkah 1)
        final sortedList = List<Transaksi>.from(filteredList);
        sortedList.sort((a, b) {
          int result = 0;
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
            // --- TAMBAHKAN LOGIKA BARU DI SINI ---
            case 3:
              result = a.bMerk.merk.compareTo(b.bMerk.merk);
              break;
            case 4:
              result = a.cTypeChassis.typeChassis.compareTo(
                b.cTypeChassis.typeChassis,
              );
              break;
            case 5:
              result = a.dJenisKendaraan.jenisKendaraan.compareTo(
                b.dJenisKendaraan.jenisKendaraan,
              );
              break;
            case 6:
              result = a.fPengajuan.jenisPengajuan.compareTo(
                b.fPengajuan.jenisPengajuan,
              );
              break;
            // --- AKHIR LOGIKA BARU ---
            case 7:
              result = a.user.name.compareTo(b.user.name);
              break;
            case 8:
              result = a.createdAt.compareTo(b.createdAt);
              break;
            case 9:
              result = a.updatedAt.compareTo(b.updatedAt);
              break;
          }
          return _sortAscending ? result : -result;
        });

        // LANGKAH 3: Gunakan 'soredList' (yang sudah difilter dan di-sor)
        final dataSource = TransaksiDataSource(
          sortedList,
          authService,
          currentUserId,
          context,
          ref,
        );

        // 3. GANTI DataTable2 MENJADI PaginatedDataTable2
        return PaginatedDataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1600,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,

          // --- KONTROL PAGINASI DAN ENTRIES ---
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: const [25, 50, 100],
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

  // Helper function untuk membuat kolom dengan logic onSor
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
        onSort: _onSort,
      ), // Contoh kolom tanpa sor
      DataColumn2(
        label: Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: Text('Jenis\nKendaraan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: Text('Jenis\nPengajuan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(label: Text('User'), size: ColumnSize.S, onSort: _onSort),
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
