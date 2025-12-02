import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/widgets/user/edit_user_dialog.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/app_user.dart';

class UserDataSource extends DataTableSource {
  final List<AppUser> users;
  final int totalRecords;
  final int rowsPerPage;
  final int currentPage;
  final BuildContext context;
  final WidgetRef ref;

  UserDataSource({
    required this.users,
    required this.totalRecords,
    required this.rowsPerPage,
    required this.currentPage,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final int localIndex = index - ((currentPage - 1) * rowsPerPage);

    if (localIndex < 0 || localIndex >= users.length) {
      return null;
    }

    final user = users[localIndex];
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final authToken = ref.read(authTokenProvider);
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

    return DataRow(
      cells: [
        DataCell(SelectableText(user.name)),
        DataCell(SelectableText(user.username)),
        DataCell(Text(user.role?.name ?? 'N/A')),
        DataCell(SelectableText(user.hint ?? '')),
        DataCell(
          (user.signature != null &&
                  user.signature!.isNotEmpty &&
                  authToken != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.network(
                    // Gunakan baseUrl dari Dio
                    '$baseUrl/admin/users/${user.id}/paraf?v=${user.updatedAt.millisecondsSinceEpoch}',
                    headers: {'Authorization': 'Bearer $authToken'},
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.orange),
                  ),
                )
              : const Icon(
                  Icons.cancel,
                  size: 15,
                  color: Colors.red,
                  semanticLabel: 'Tidak Ada',
                ),
        ),
        DataCell(SelectableText(dateFormat.format(user.createdAt.toLocal()))),
        DataCell(SelectableText(dateFormat.format(user.updatedAt.toLocal()))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 15),
                tooltip: 'Edit User',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditUserDialog(user: user),
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
  int get rowCount => totalRecords;

  @override
  int get selectedRowCount => 0;
}
