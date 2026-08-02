// File: lib/elements/home/widgets/detail_skrb/replace_history_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/admin/master/widgets/pdf_viewer_dialog.dart';
import 'package:master_gambar/app/core/app_helpers.dart';
import '../../providers/skrb_providers.dart';
import '../../repository/skrb_repository.dart';

class ReplaceHistoryDialog extends ConsumerStatefulWidget {
  final Skrb skrb;
  final VoidCallback onMergeAfterDelete;

  const ReplaceHistoryDialog({
    super.key,
    required this.skrb,
    required this.onMergeAfterDelete,
  });

  @override
  ConsumerState<ReplaceHistoryDialog> createState() =>
      _ReplaceHistoryDialogState();
}

class _ReplaceHistoryDialogState extends ConsumerState<ReplaceHistoryDialog> {
  bool _isProcessing = false;
  int? _activeHistoryId;

  @override
  Widget build(BuildContext context) {
    final skrbAsync = ref.watch(skrbDetailProvider(widget.skrb.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.published_with_changes_rounded,
            color: Colors.purple.shade500,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Replace History SKRB (${widget.skrb.idSkrb})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 680,
        height: 400,
        child: Column(
          children: [
            // Banner Penjelasan Solutif & Efisien
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.purple.shade900.withAlpha(80)
                    : Colors.purple.shade50,
                border: Border.all(
                  color: isDark
                      ? Colors.purple.shade400
                      : Colors.purple.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: isDark
                        ? Colors.purple.shade200
                        : Colors.purple.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cara Instan Replace & Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark
                                ? Colors.purple.shade200
                                : Colors.purple.shade900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Solusi cepat tanpa repot buka-tutup menu History saat Mode Edit! Pilih salah satu file di bawah yang ingin ditimpa (dihapus) dan digantikan seketika dengan dokumen SKRB editan terbaru Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.purple.shade100
                                : Colors.purple.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildHistoryContent(skrbAsync)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal & Tutup'),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(AsyncValue<Skrb> skrbAsync) {
    return skrbAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error memuat riwayat: $err')),
      data: (skrb) {
        if (skrb.histories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada file riwayat SKRB tersimpan yang bisa ditimpa.\nSilakan langsung tekan tombol "Simpan" di bar navigasi utama.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: skrb.histories.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, index) {
            final h = skrb.histories[index];
            final isLoadingThis = _isProcessing && _activeHistoryId == h.id;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 32,
              ),
              title: Text(
                h.fileName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Ukuran: ${formatFileSize(h.fileSize)}   |   Waktu: ${formatDateTime(h.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingThis)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else ...[
                    // Preview
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      tooltip: 'Preview PDF',
                      onPressed: () => _handlePreview(h),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Replace Ini
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.published_with_changes, size: 18),
                      label: const Text('Replace Ini'),
                      onPressed: () => _confirmReplace(h),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handlePreview(SkrbHistoryItem history) async {
    setState(() {
      _isProcessing = true;
      _activeHistoryId = history.id;
    });

    try {
      final repo = ref.read(skrbRepositoryProvider);
      final url = repo.getHistoryViewUrl(history.id);
      final bytes = await repo.getPdfBytes(url);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => PdfViewerDialog(
            pdfData: bytes,
            title: 'Preview Arsip: ${history.fileName}',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka preview: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeHistoryId = null;
        });
      }
    }
  }

  void _confirmReplace(SkrbHistoryItem history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 26,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Konfirmasi Timpa & Simpan (Replace)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah kamu yakin ingin mereplace file ini?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      history.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Proses otomatis yang akan dijalankan:\n'
              '1. Dokumen versi lama di atas akan langsung dihapus dari server untuk mengosongkan slot arsip Anda.\n'
              '2. Sistem seketika membuat dan menyatukan (merging) dokumen SKRB baru dari hasil editan Anda saat ini sebagai pengirim baru.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Ya, Replace & Simpan Baru'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Tutup dialog konfirmasi
              await _executeReplace(history);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _executeReplace(SkrbHistoryItem history) async {
    setState(() {
      _isProcessing = true;
      _activeHistoryId = history.id;
    });

    try {
      // 1. Hapus file history lawas terlebih dahulu dari server
      await ref.read(skrbRepositoryProvider).deleteHistory(history.id);
      final _ = await ref.refresh(skrbDetailProvider(widget.skrb.id).future);
      ref.invalidate(skrbListProvider);
      ref.invalidate(skrbStorageInfoProvider(widget.skrb.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File lama berhasil dihapus. Menyematkan file SKRB versi terbaru...',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 3),
          ),
        );
        // 2. Tutup dialog replace ini
        Navigator.of(context).pop();
        // 3. Trigger merge / simpan file baru ke server
        widget.onMergeAfterDelete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat mereplace file: $e')),
        );
        setState(() {
          _isProcessing = false;
          _activeHistoryId = null;
        });
      }
    }
  }
}
