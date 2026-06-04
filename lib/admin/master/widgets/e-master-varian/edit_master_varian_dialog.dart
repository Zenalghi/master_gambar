import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import '../../../../../data/models/option_item.dart';
import '../../models/master_varian.dart';
import '../../providers/master_data_providers.dart';
import '../../repository/master_data_repository.dart';

class EditMasterVarianDialog extends ConsumerStatefulWidget {
  final MasterVarian masterVarian;

  const EditMasterVarianDialog({super.key, required this.masterVarian});

  @override
  ConsumerState<EditMasterVarianDialog> createState() =>
      _EditMasterVarianDialogState();
}

class _EditMasterVarianDialogState
    extends ConsumerState<EditMasterVarianDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaVarianController;
  int? _selectedJenisKendaraanId;
  OptionItem? _initialJenisKendaraan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaVarianController = TextEditingController(
      text: widget.masterVarian.namaVarian,
    );
    _selectedJenisKendaraanId = widget.masterVarian.dJenisKendaraanId;

    if (widget.masterVarian.jenisKendaraan != null) {
      _initialJenisKendaraan = OptionItem(
        id: widget.masterVarian.jenisKendaraan!.id,
        name: widget.masterVarian.jenisKendaraan!.name,
      );
    }
  }

  @override
  void dispose() {
    _namaVarianController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .updateMasterVarian(
            id: widget.masterVarian.id,
            jenisKendaraanId: _selectedJenisKendaraanId!,
            namaVarian: _namaVarianController.text,
          );

      ref
          .read(masterVarianFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.response?.data['message'] ?? e.message}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Master Varian #${widget.masterVarian.id}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownSearch<OptionItem>(
                items: (String filter, _) =>
                    ref.read(mdJenisKendaraanOptionsProvider(filter).future),
                itemAsString: (OptionItem item) => item.name,
                compareFn: (item1, item2) => item1.id == item2.id,
                selectedItem: _initialJenisKendaraan,
                onChanged: (OptionItem? item) {
                  _selectedJenisKendaraanId = item?.id as int?;
                },
                decoratorProps: const DropDownDecoratorProps(
                  baseStyle: TextStyle(fontSize: 13, height: 1.0),
                  decoration: InputDecoration(
                    labelText: 'Jenis Kendaraan',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                popupProps: const PopupProps.menu(showSearchBox: true),
                validator: (item) => item == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaVarianController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nama Varian',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
