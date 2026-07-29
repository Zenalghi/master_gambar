// lib/admin/management/document_customer_screen.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/app/theme/app_theme.dart';
import '../../data/models/customer.dart';
import 'providers/customer_providers.dart';
import 'repository/customer_repository.dart';
import 'widgets/document/document_customer_form.dart';

class DocumentCustomerScreen extends ConsumerWidget {
  const DocumentCustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomer = ref.watch(selectedDocumentCustomerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptasi warna dengan app_theme.dart:
    // - Light Mode: Menggunakan AppColors.primary (Biru gelap/tegas yang jelas di background terang)
    // - Dark Mode : Menggunakan colorScheme.primary (Biru cerah kontras dari turunan seed AppColors.primary untuk backgroundDark)
    final customerNameColor = isDark
        ? Theme.of(context).colorScheme.primary
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Document Customer :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 360,
                child: DropdownSearch<Customer>(
                  selectedItem: selectedCustomer,
                  items: (String filter, _) async {
                    final res = await ref
                        .read(customerRepositoryProvider)
                        .getCustomers(
                          page: 1,
                          rowsPerPage: 25,
                          sortBy: 'nama_pt',
                          sortAscending: true,
                          searchQuery: filter,
                        );
                    return res.data;
                  },
                  itemAsString: (Customer item) => item.namaPt,
                  compareFn: (i1, i2) => i1.id == i2.id,
                  onChanged: (Customer? customer) {
                    ref.read(selectedDocumentCustomerProvider.notifier).state =
                        customer;
                  },
                  decoratorProps: DropDownDecoratorProps(
                    baseStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selectedCustomer != null
                          ? customerNameColor
                          : null,
                    ),
                    decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 42),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      hintText: 'Cari & pilih Customer...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      autofocus: true,
                      style: TextStyle(fontSize: 13, height: 1.0),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 42),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        hintStyle: TextStyle(fontSize: 13, height: 1.0),
                        hintText: "Cari nama Customer...",
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    itemBuilder: (context, item, isSelected, isDisabled) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                                    .withValues(alpha: 0.3)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.namaPt,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'PJ: ${item.pj}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const _RecipientAddressDialog(),
                ),
                icon: const Icon(Icons.markunread_mailbox_outlined, size: 18),
                label: const Text(
                  'Input Identifikasi dan Alamat Penerima',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 6),
          // Konten Document
          Expanded(
            child: selectedCustomer != null
                ? _DocumentContent(customerId: selectedCustomer.id)
                : const Center(
                    child: Text(
                      'Silahkan cari & pilih Customer pada dropdown di atas atau klik ikon Document pada tabel Customer.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget internal untuk memuat dan menampilkan DocumentCustomerForm
class _DocumentContent extends ConsumerWidget {
  final int customerId;
  const _DocumentContent({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentCustomerProvider(customerId));

    return docAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat dokumen: $err',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.refresh(documentCustomerProvider(customerId)),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      data: (document) {
        return DocumentCustomerForm(
          key: ValueKey('doc_${customerId}_${document?.id ?? 'new'}'),
          customerId: customerId,
          initialDocument: document,
        );
      },
    );
  }
}

/// Dialog untuk mengatur Identifikasi dan Alamat Penerima global (SKRB).
class _RecipientAddressDialog extends ConsumerStatefulWidget {
  const _RecipientAddressDialog();

  @override
  ConsumerState<_RecipientAddressDialog> createState() =>
      _RecipientAddressDialogState();
}

class _RecipientAddressDialogState
    extends ConsumerState<_RecipientAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get('/skrb-setting');
      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['recipient_address']?.toString() ?? '';
        _controller.text = address;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data alamat penerima: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(apiClientProvider).dio;
      await dio.post(
        '/skrb-setting',
        data: {'recipient_address': _controller.text.trim()},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Identifikasi dan alamat penerima berhasil disimpan!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          backgroundColor: Colors.white,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Gagal menyimpan: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.markunread_mailbox, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Input Identifikasi & Alamat Penerima',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: _isLoading
            ? const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat ini berlaku umum (global) pada dokumen pengajuan SKRB ke Kementerian Perhubungan dan terpisah dari data customer.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Text(
                      'Identifikasi & Alamat Tujuan (Tekan Enter / Shift+Enter untuk baris baru) :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller,
                      maxLines: 7,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Contoh:\nBapak Direktur Jendral Perhubungan Darat\nCq. Direktur Sarana dan Keselamatan\nTransportasi Jalan\nJl. Merdeka Barat No.8\nDi Jakarta',
                        contentPadding: EdgeInsets.all(12),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Identifikasi dan alamat penerima tidak boleh kosong / dihapus!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton.icon(
          onPressed: (_isLoading || _isSaving) ? null : _saveData,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 16),
          label: const Text('Simpan'),
        ),
      ],
    );
  }
}
