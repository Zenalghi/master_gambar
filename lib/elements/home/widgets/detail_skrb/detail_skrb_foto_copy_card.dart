// File: lib/elements/home/widgets/detail_skrb/detail_skrb_foto_copy_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/elements/home/providers/skrb_providers.dart';
import 'package:master_gambar/elements/home/repository/skrb_repository.dart';

class DetailSkrbFotoCopyCard extends ConsumerStatefulWidget {
  final Skrb skrb;
  final bool isLocked;
  final VoidCallback onLiveUpdate;

  const DetailSkrbFotoCopyCard({
    super.key,
    required this.skrb,
    required this.isLocked,
    required this.onLiveUpdate,
  });

  @override
  ConsumerState<DetailSkrbFotoCopyCard> createState() =>
      _DetailSkrbFotoCopyCardState();
}

class _DetailSkrbFotoCopyCardState
    extends ConsumerState<DetailSkrbFotoCopyCard> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initFromSkrb();
  }

  void _initFromSkrb() {
    final val =
        widget.skrb.fotoCopySkrb ??
        widget.skrb.snapshotDocuments['foto_copy_skrb']?.toString() ??
        '';
    _controller = TextEditingController(text: val == '-' ? '' : val);
  }

  @override
  void didUpdateWidget(covariant DetailSkrbFotoCopyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skrb.id != widget.skrb.id) {
      final val =
          widget.skrb.fotoCopySkrb ??
          widget.skrb.snapshotDocuments['foto_copy_skrb']?.toString() ??
          '';
      _controller.text = val == '-' ? '' : val;
    } else if (_debounce?.isActive != true && !_isUpdating) {
      final val =
          widget.skrb.fotoCopySkrb ??
          widget.skrb.snapshotDocuments['foto_copy_skrb']?.toString() ??
          '';
      final cleanVal = val == '-' ? '' : val;
      if (_controller.text != cleanVal) {
        _controller.text = cleanVal;
      }
    }
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _sendUpdateToServer();
    });
  }

  Future<void> _sendUpdateToServer() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final repo = ref.read(skrbRepositoryProvider);
      await repo.updateFotoCopySkrb(widget.skrb.id, _controller.text);
      ref.invalidate(skrbDetailProvider(widget.skrb.id));
      widget.onLiveUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui Foto Copy SKRB: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                'Foto Copy SKRB No: (Kelengkapan Permohonan d.)',
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sync ke Server...',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _controller,
            enabled: !widget.isLocked,
            maxLines: 7,
            onChanged: _onTextChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ketik Nomor / Keterangan Foto Copy SKRB (opsional)...',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: scheme.outline.withAlpha(80)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
