// File: lib/elements/home/widgets/detail_skrb/detail_skrb_footer.dart
import 'package:flutter/material.dart';
import 'package:master_gambar/data/models/skrb.dart';

class DetailSkrbFooter extends StatelessWidget {
  final Skrb skrb;
  final bool isProcessing;
  final Future<void> Function({required bool download}) onMerge;
  final Future<void> Function(int targetPhase) onSwitchPhase;
  final VoidCallback onResetFiles;
  final VoidCallback onShowHistory;

  const DetailSkrbFooter({
    super.key,
    required this.skrb,
    required this.isProcessing,
    required this.onMerge,
    required this.onSwitchPhase,
    required this.onResetFiles,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxHistory = skrb.histories.length >= 3;
    final isExpired = skrb.statusTdp.toLowerCase().contains('exp');
    final expiredTooltip = 'Dokumen TDP sudah Expired.\nHubungi Admin';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          if (skrb.fase == 1) ...[
            Expanded(
              child: Tooltip(
                message: isExpired
                    ? expiredTooltip
                    : 'Simpan ke server', // dan beralih ke Fase 2
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired
                        ? Colors.grey.shade600
                        : Colors.blue.shade700,
                    foregroundColor: isExpired
                        ? Colors.grey.shade300
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan ke Server'), // (Fase 2)
                  onPressed: (isProcessing || isExpired)
                      ? null
                      : () => onMerge(download: false),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Tooltip(
                message: isExpired
                    ? expiredTooltip
                    : 'Simpan ke server dan unduh file PDF',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired
                        ? Colors.grey.shade600
                        : Colors.green.shade700,
                    foregroundColor: isExpired
                        ? Colors.grey.shade300
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Simpan dan Unduh'),
                  onPressed: (isProcessing || isExpired)
                      ? null
                      : () => onMerge(download: true),
                ),
              ),
            ),
          ],
          if (skrb.fase == 2) ...[
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.edit_note),
                label: const Text('Mode Edit'), // (Fase 3)
                onPressed: isProcessing ? null : () => onSwitchPhase(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Hapus & Reset'), // ke Fase 1
                onPressed: isProcessing ? null : onResetFiles,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.history_edu),
                label: const Text('History SKRB'),
                onPressed: onShowHistory,
              ),
            ),
          ],
          if (skrb.fase == 3) ...[
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.cancel, color: Colors.orange),
                label: const Text(
                  'Batal Edit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: isProcessing ? null : () => onSwitchPhase(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: isExpired
                    ? expiredTooltip
                    : (isMaxHistory
                          ? '⚠️ Riwayat dokumen SKRB sudah mencapai batas maksimal (3/3). Harap bersihkan atau hapus minimal 1 riwayat terlebih dahulu di menu History SKRB.'
                          : 'Simpan perubahan'), // dan beralih ke Fase 2
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isMaxHistory || isExpired)
                        ? Colors.grey.shade600
                        : Colors.blue.shade700,
                    foregroundColor: (isMaxHistory || isExpired)
                        ? Colors.grey.shade300
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  onPressed: (isProcessing || isMaxHistory || isExpired)
                      ? null
                      : () => onMerge(download: false),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: isExpired
                    ? expiredTooltip
                    : (isMaxHistory
                          ? 'ℹ️ Riwayat SKRB sudah penuh (3/3). Dokumen akan langsung diunduh TANPA disimpan ke server. Bersihkan riwayat jika ingin menyematkan file baru.'
                          : 'Simpan ke server dan unduh salinan PDF'),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired
                        ? Colors.grey.shade600
                        : Colors.green.shade700,
                    foregroundColor: isExpired
                        ? Colors.grey.shade300
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.file_download),
                  label: Text(
                    isMaxHistory ? 'Download Saja' : 'Simpan dan Unduh',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: (isProcessing || isExpired)
                      ? null
                      : () => onMerge(download: true),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Hapus & Reset'),
                onPressed: isProcessing ? null : onResetFiles,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.history_edu),
                label: const Text('History'),
                onPressed: onShowHistory,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
