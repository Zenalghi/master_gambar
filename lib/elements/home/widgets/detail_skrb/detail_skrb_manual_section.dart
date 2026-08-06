// File: lib/elements/home/widgets/detail_skrb/detail_skrb_manual_section.dart

import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/skrb_providers.dart';
import 'package:master_gambar/elements/home/repository/skrb_repository.dart';

class DetailSkrbManualSection extends ConsumerStatefulWidget {
  final Skrb skrb;
  final bool isLocked;
  final VoidCallback onLiveUpdate;

  const DetailSkrbManualSection({
    super.key,
    required this.skrb,
    required this.isLocked,
    required this.onLiveUpdate,
  });

  @override
  ConsumerState<DetailSkrbManualSection> createState() =>
      _DetailSkrbManualSectionState();
}

class _DetailSkrbManualSectionState
    extends ConsumerState<DetailSkrbManualSection> {
  final List<Map<String, dynamic>> _localList = [];
  List<Map<String, dynamic>>? _undoBackup;
  Timer? _debounce;
  bool _isUpdating = false;
  DateTime? _lastActionTime;

  late TextEditingController _merkTipeController;
  late TextEditingController _jenisController;
  late TextEditingController _peruntukanController;
  final List<TextEditingController> _varianControllers = [];

  @override
  void initState() {
    super.initState();
    _merkTipeController = TextEditingController();
    _jenisController = TextEditingController();
    _peruntukanController = TextEditingController();
    _initFromSkrb();
  }

  @override
  void didUpdateWidget(covariant DetailSkrbManualSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skrb.id != widget.skrb.id) {
      _initFromSkrb();
    } else if (_debounce?.isActive != true && !_isUpdating) {
      if (_lastActionTime != null &&
          DateTime.now().difference(_lastActionTime!).inSeconds < 6) {
        return;
      }
      final serverList = _extractFromSkrb(widget.skrb);
      if (serverList.length != _localList.length) {
        _initFromSkrb();
      }
    }
  }

  String _getDefaultMerkTipe() {
    final merk = widget.skrb.snapshotDocuments['merk']?.toString().trim() ?? '';
    final chassis =
        widget.skrb.snapshotDocuments['type_chassis']?.toString().trim() ?? '';
    if (merk.isNotEmpty &&
        merk != '-' &&
        chassis.isNotEmpty &&
        chassis != '-') {
      return '$merk TIPE $chassis';
    }
    return '';
  }

  String _getDefaultJenis() {
    return widget.skrb.snapshotDocuments['jenis_tipe']?.toString().trim() ?? '';
  }

  String _getDefaultPeruntukan() {
    return widget.skrb.snapshotDocuments['alias_kendaraan']
            ?.toString()
            .trim() ??
        '';
  }

  List<Map<String, dynamic>> _extractFromSkrb(Skrb skrb) {
    final raw =
        skrb.snapshotDocuments['manual_gambar_list'] ??
        skrb.snapshotDocuments['gambar_utama_list'];
    if (raw != null && raw is List && raw.isNotEmpty) {
      return raw
          .map<Map<String, dynamic>>((item) {
            if (item is Map) {
              return {
                'key': '${item['key'] ?? 'a'}',
                'index': item['index'] ?? 1,
                'judul': '${item['judul'] ?? 'Varian Standar'}',
                'varian': '${item['varian'] ?? ''}',
                'judul_id': item['judul_id'],
                'varian_id': item['varian_id'],
              };
            }
            return {};
          })
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return [
      {
        'key': 'a',
        'index': 1,
        'judul': 'Varian Standar',
        'varian': '',
        'judul_id': null,
        'varian_id': null,
      },
    ];
  }

  void _initFromSkrb() {
    _undoBackup = null;
    _localList.clear();

    final doc = widget.skrb.snapshotDocuments;
    final manualMerk = doc['manual_merk_tipe']?.toString();
    final manualJenis = doc['manual_jenis']?.toString();
    final manualPeruntukan = doc['manual_peruntukan']?.toString();

    _merkTipeController.text = (manualMerk != null && manualMerk.isNotEmpty)
        ? manualMerk
        : _getDefaultMerkTipe();
    _jenisController.text = (manualJenis != null && manualJenis.isNotEmpty)
        ? manualJenis
        : _getDefaultJenis();
    _peruntukanController.text =
        (manualPeruntukan != null && manualPeruntukan.isNotEmpty)
        ? manualPeruntukan
        : _getDefaultPeruntukan();

    final items = _extractFromSkrb(widget.skrb);
    for (var controller in _varianControllers) {
      controller.dispose();
    }
    _varianControllers.clear();

    for (var item in items) {
      _localList.add(Map<String, dynamic>.from(item));
      _varianControllers.add(
        TextEditingController(text: '${item['varian'] ?? ''}'),
      );
    }
  }

  void _reindexKeys() {
    final keys = ['a', 'b', 'c', 'd'];
    for (int i = 0; i < _localList.length; i++) {
      _localList[i]['key'] = keys[i];
      _localList[i]['index'] = i + 1;
    }
  }

  Future<void> _sendUpdateToServer() async {
    _lastActionTime = DateTime.now();
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final repo = ref.read(skrbRepositoryProvider);
      await repo.updatePermohonanManualSpecs(
        widget.skrb.id,
        manualMerkTipe: _merkTipeController.text.trim(),
        manualJenis: _jenisController.text.trim(),
        manualPeruntukan: _peruntukanController.text.trim(),
        gambarUtamaList: _localList,
      );
      ref.invalidate(skrbDetailProvider(widget.skrb.id));
      widget.onLiveUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui Permohonan Manual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
        _lastActionTime = DateTime.now();
      }
    }
  }

  void _onFieldChanged() {
    _lastActionTime = DateTime.now();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _sendUpdateToServer);
  }

  void _addRow() {
    if (_localList.length >= 4 || widget.isLocked) return;
    _undoBackup ??= _localList
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final nextIdx = _localList.length;
    final keys = ['a', 'b', 'c', 'd'];
    _localList.add({
      'key': keys[nextIdx],
      'index': nextIdx + 1,
      'judul': 'Varian ${nextIdx + 1}',
      'varian': '',
      'judul_id': null,
      'varian_id': null,
    });
    _varianControllers.add(TextEditingController(text: ''));
    setState(() {});
    _sendUpdateToServer();
  }

  void _deleteRow(int index) {
    if (_localList.length <= 1 || widget.isLocked) return;
    _undoBackup ??= _localList
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _localList.removeAt(index);
    _varianControllers[index].dispose();
    _varianControllers.removeAt(index);
    _reindexKeys();
    setState(() {});
    _sendUpdateToServer();
  }

  void _undoDelete() {
    if (_undoBackup == null || widget.isLocked) return;
    for (var controller in _varianControllers) {
      controller.dispose();
    }
    _varianControllers.clear();
    _localList.clear();
    for (var item in _undoBackup!) {
      _localList.add(Map<String, dynamic>.from(item));
      _varianControllers.add(
        TextEditingController(text: '${item['varian'] ?? ''}'),
      );
    }
    _undoBackup = null;
    setState(() {});
    _sendUpdateToServer();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _merkTipeController.dispose();
    _jenisController.dispose();
    _peruntukanController.dispose();
    for (var c in _varianControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final judulOptions = ref.watch(judulGambarOptionsProvider);

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.teal.withAlpha(25) : Colors.teal.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.teal.shade400.withAlpha(120)
              : Colors.teal.shade300,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: isDark ? Colors.teal.shade300 : Colors.teal.shade800,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Spesifikasi Permohonan (Mode Manual Kustom)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (_isUpdating)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sync ke Server...',
                      style: TextStyle(fontSize: 11, color: scheme.primary),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Semua data di bawah ini (a, b, c, dan d) akan dicetak pada Surat Permohonan.',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),

          // Fields a, b, c
          _buildTextFieldRow(
            'a.',
            'Merk / Tipe',
            _merkTipeController,
            'Ketik Merk & Tipe Manual...',
          ),
          const SizedBox(height: 8),
          _buildTextFieldRow(
            'b.',
            'Jenis',
            _jenisController,
            'Ketik Jenis Kendaraan Manual...',
          ),
          const SizedBox(height: 8),
          _buildTextFieldRow(
            'c.',
            'Peruntukan',
            _peruntukanController,
            'Ketik Peruntukan Manual...',
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Text(
            'd. Daftar Varian Body (Gambar)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // List Varian
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _localList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final item = _localList[i];
              final int? currentJudulId = item['judul_id'] as int?;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal.withAlpha(40)
                          : Colors.teal.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Gambar ${i + 1}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.teal.shade300
                            : Colors.teal.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 136,
                    height: 46,
                    child: IgnorePointer(
                      ignoring: widget.isLocked,
                      child: Opacity(
                        opacity: widget.isLocked ? 0.6 : 1.0,
                        child: judulOptions.when(
                          data: (items) {
                            final selectedOption = items
                                .where((e) => e.id == currentJudulId)
                                .firstOrNull;

                            return DropdownSearch<OptionItem>(
                              items: (filter, _) => items
                                  .where(
                                    (e) => e.name.toLowerCase().contains(
                                      filter.toLowerCase(),
                                    ),
                                  )
                                  .toList(),
                              itemAsString: (OptionItem item) => item.name,
                              compareFn: (i1, i2) => i1.id == i2.id,
                              selectedItem: selectedOption,
                              onChanged: (OptionItem? selected) {
                                if (selected != null) {
                                  _undoBackup ??= _localList
                                      .map((e) => Map<String, dynamic>.from(e))
                                      .toList();
                                  _localList[i]['judul'] = selected.name;
                                  _localList[i]['judul_id'] = selected.id;
                                  setState(() {});
                                  _onFieldChanged();
                                }
                              },
                              decoratorProps: const DropDownDecoratorProps(
                                baseStyle: TextStyle(fontSize: 13, height: 1.2),
                                decoration: InputDecoration(
                                  hintText: 'Pilih Judul',
                                  border: OutlineInputBorder(),
                                  constraints: BoxConstraints(
                                    minHeight: 46,
                                    maxHeight: 46,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: const TextFieldProps(
                                  autofocus: true,
                                  style: TextStyle(fontSize: 13, height: 1.0),
                                  decoration: InputDecoration(
                                    constraints: BoxConstraints(maxHeight: 38),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 10,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      height: 1.0,
                                    ),
                                    hintText: "Cari Judul...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                                itemBuilder:
                                    (context, item, isSelected, isDisabled) =>
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          height: 30,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.0,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? scheme.primary
                                                  : scheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                              ),
                            );
                          },
                          loading: () => const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (_, __) => const Text(
                            'Gagal load judul',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        controller: _varianControllers[i],
                        readOnly: widget.isLocked,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          isDense: true,
                          constraints: const BoxConstraints(
                            minHeight: 46,
                            maxHeight: 46,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          border: const OutlineInputBorder(),
                          hintText: 'Ketik Nama Varian Body Manual...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant.withAlpha(150),
                          ),
                        ),
                        onChanged: (val) {
                          _undoBackup ??= _localList
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList();
                          _localList[i]['varian'] = val;
                          _onFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_localList.length > 1 && !widget.isLocked)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                      tooltip: 'Hapus baris ini',
                      onPressed: () => _deleteRow(i),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    )
                  else
                    const SizedBox(width: 28),
                ],
              );
            },
          ),

          if (!widget.isLocked &&
              (_localList.length < 4 || _undoBackup != null)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_localList.length < 4)
                  TextButton.icon(
                    onPressed: _addRow,
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: isDark
                          ? Colors.teal.shade300
                          : Colors.teal.shade700,
                    ),
                    label: Text(
                      'Tambah Varian',
                      style: TextStyle(
                        color: isDark
                            ? Colors.teal.shade300
                            : Colors.teal.shade700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (_undoBackup != null) ...[
                  if (_localList.length < 4) const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _undoDelete,
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Kembalikan'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(
    String prefix,
    String label,
    TextEditingController controller,
    String hint,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(
            prefix,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: scheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: controller,
              readOnly: widget.isLocked,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                constraints: const BoxConstraints(minHeight: 46, maxHeight: 46),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                border: const OutlineInputBorder(),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant.withAlpha(150),
                ),
              ),
              onChanged: (val) => _onFieldChanged(),
            ),
          ),
        ),
      ],
    );
  }
}
