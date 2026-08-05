// File: lib/elements/home/widgets/detail_skrb/detail_skrb_gambar_section.dart

import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/skrb_providers.dart';
import 'package:master_gambar/elements/home/repository/skrb_repository.dart';

class DetailSkrbGambarSection extends ConsumerStatefulWidget {
  final Skrb skrb;
  final bool isLocked;
  final VoidCallback onLiveUpdate;

  const DetailSkrbGambarSection({
    super.key,
    required this.skrb,
    required this.isLocked,
    required this.onLiveUpdate,
  });

  @override
  ConsumerState<DetailSkrbGambarSection> createState() =>
      _DetailSkrbGambarSectionState();
}

class _DetailSkrbGambarSectionState
    extends ConsumerState<DetailSkrbGambarSection> {
  final List<Map<String, dynamic>> _localList = [];
  List<Map<String, dynamic>>? _undoBackup;
  Timer? _debounce;
  bool _isUpdating = false;
  DateTime? _lastActionTime;

  @override
  void initState() {
    super.initState();
    _initFromSkrb();
  }

  @override
  void didUpdateWidget(covariant DetailSkrbGambarSection oldWidget) {
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

  List<Map<String, dynamic>> _extractFromSkrb(Skrb skrb) {
    final raw = skrb.snapshotDocuments['gambar_utama_list'];
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

    final items = _extractFromSkrb(widget.skrb);
    for (var item in items) {
      _localList.add(Map<String, dynamic>.from(item));
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
      await repo.updateGambarUtamaList(widget.skrb.id, _localList);
      ref.invalidate(skrbDetailProvider(widget.skrb.id));
      widget.onLiveUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui Varian Body: $e'),
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
    setState(() {});
    _sendUpdateToServer();
  }

  void _deleteRow(int index) {
    if (_localList.length <= 1 || widget.isLocked) return;
    _undoBackup ??= _localList
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _localList.removeAt(index);
    _reindexKeys();
    setState(() {});
    _sendUpdateToServer();
  }

  void _undoDelete() {
    if (_undoBackup == null || widget.isLocked) return;
    _localList.clear();
    for (var item in _undoBackup!) {
      _localList.add(Map<String, dynamic>.from(item));
    }
    _undoBackup = null;
    setState(() {});
    _sendUpdateToServer();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final judulOptions = ref.watch(judulGambarOptionsProvider);
    final defaultParams = VarianFilterParams(
      search: '',
      masterDataId: widget.skrb.masterDataId,
    );
    final varianBodyOptionsAsync = ref.watch(
      varianBodyStatusOptionsProvider(defaultParams),
    );

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Varian Body (Permohonan Varian)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
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
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _localList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final item = _localList[i];
              final int? currentJudulId = item['judul_id'] as int?;

              return Row(
                children: [
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Gambar ${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 128,
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
                                      .map(
                                        (e) => Map<String, dynamic>.from(e),
                                      )
                                      .toList();
                                  _localList[i]['judul'] = selected.name;
                                  _localList[i]['judul_id'] = selected.id;
                                  setState(() {});
                                  _sendUpdateToServer();
                                }
                              },
                              decoratorProps: const DropDownDecoratorProps(
                                baseStyle: TextStyle(fontSize: 13, height: 1.0),
                                decoration: InputDecoration(
                                  hintText: 'Pilih Judul',
                                  border: OutlineInputBorder(),
                                  constraints: BoxConstraints(maxHeight: 38),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
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
                                    constraints: BoxConstraints(maxHeight: 40),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    hintText: "Cari Judul...",
                                    prefixIcon: Icon(Icons.search, size: 18),
                                  ),
                                ),
                                itemBuilder:
                                    (context, item, isSelected, isDisabled) {
                                      return Container(
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        color: isSelected
                                            ? scheme.primary.withValues(
                                                alpha: 0.12,
                                              )
                                            : null,
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? scheme.primary
                                                : scheme.onSurface,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                menuProps: const MenuProps(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 38,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox(
                            height: 38,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Gagal muat judul',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: widget.isLocked,
                      child: Opacity(
                        opacity: widget.isLocked ? 0.6 : 1.0,
                        child: varianBodyOptionsAsync.when(
                          skipLoadingOnRefresh: false,
                          data: (defaultItems) {
                            OptionItem? selectedOption = defaultItems
                                .where((e) => e.id == _localList[i]['varian_id'])
                                .firstOrNull;
                            if (selectedOption == null && _localList[i]['varian'] != null && (_localList[i]['varian'] as String).isNotEmpty) {
                              selectedOption = defaultItems
                                  .where((e) => e.name == _localList[i]['varian'])
                                  .firstOrNull;
                            }

                            return DropdownSearch<OptionItem>(
                              items: (String filter, _) {
                                final params = VarianFilterParams(
                                  search: filter,
                                  masterDataId: widget.skrb.masterDataId,
                                );
                                return ref.read(
                                  varianBodyStatusOptionsProvider(params).future,
                                );
                              },
                              itemAsString: (OptionItem item) => item.name,
                              compareFn: (i1, i2) => i1.id == i2.id,
                              selectedItem: selectedOption,
                              onChanged: (OptionItem? item) {
                                if (_undoBackup == null) {
                                  _undoBackup = _localList
                                      .map((e) => Map<String, dynamic>.from(e))
                                      .toList();
                                }
                                _lastActionTime = DateTime.now();
                                setState(() {
                                  _localList[i]['varian_id'] = item?.id;
                                  _localList[i]['varian'] = item?.name ?? '';
                                });
                                _debounce?.cancel();
                                _debounce = Timer(
                                  const Duration(milliseconds: 600),
                                  _sendUpdateToServer,
                                );
                              },
                              decoratorProps: const DropDownDecoratorProps(
                                baseStyle: TextStyle(fontSize: 13, height: 1.0),
                                decoration: InputDecoration(
                                  constraints: BoxConstraints(maxHeight: 42),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  labelStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(),
                                  hintText: 'Pilih Varian Body...',
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
                                    hintText: "Cari Varian Body...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                                itemBuilder: (context, item, isSelected, isDisabled) {
                                  final hasGambar = item.hasGambar;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    height: 30,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.0,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : (hasGambar
                                                        ? FontWeight.normal
                                                        : FontWeight.bold),
                                              color: hasGambar
                                                  ? (isSelected
                                                        ? scheme.primary
                                                        : scheme.onSurface)
                                                  : scheme.error,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        hasGambar
                                            ? Icon(
                                                Icons.check_circle,
                                                color: scheme.tertiary,
                                                size: 14,
                                              )
                                            : Text(
                                                "Belum Upload",
                                                style: TextStyle(
                                                  color: scheme.error,
                                                  fontSize: 10,
                                                ),
                                              ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 42,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => SizedBox(
                            height: 42,
                            child: Center(
                              child: Text(
                                'Error Varian',
                                style: TextStyle(color: scheme.error),
                              ),
                            ),
                          ),
                        ),
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
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Tambah Varian'),
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
                      foregroundColor: Colors.orange,
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
}
