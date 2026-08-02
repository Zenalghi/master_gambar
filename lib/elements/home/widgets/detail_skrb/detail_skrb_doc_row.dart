// File: lib/elements/home/widgets/detail_skrb/detail_skrb_doc_row.dart
import 'package:flutter/material.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/app/theme/app_theme.dart';
import 'doc_item.dart';
import 'detail_skrb_tdp_status.dart';
import 'detail_skrb_gambar_section.dart';
import 'detail_skrb_foto_copy_card.dart';

class DetailSkrbDocRow extends StatelessWidget {
  final Skrb skrb;
  final DocItem item;
  final bool isLocked;
  final bool isProcessing;
  final String? processingKey;
  final Future<void> Function(String key, bool isHidden) onToggleHide;
  final Future<void> Function(String key) onUploadFile;
  final Future<void> Function(DocItem item) onPreviewPdf;
  final VoidCallback? onLiveUpdate;

  const DetailSkrbDocRow({
    super.key,
    required this.skrb,
    required this.item,
    required this.isLocked,
    required this.isProcessing,
    required this.processingKey,
    required this.onToggleHide,
    required this.onUploadFile,
    required this.onPreviewPdf,
    this.onLiveUpdate,
  });

  String _displayKey(String k) {
    switch (k.toLowerCase()) {
      case 'a':
      case 'b':
      case 'c':
      case 'd':
        return '';
      default:
        return k.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHidden = skrb.hiddenFlags[item.key] == true;
    final isUploaded = item.hasFile;
    final isLoadingThis = isProcessing && processingKey == item.key;
    final isHidingThis = isProcessing && processingKey == 'hide_${item.key}';
    final canUpload = !isLocked && item.isOptionalUpload && !isProcessing;
    final isLivePreview = skrb.isFileUpdatedInCurrentPhase(item.key);
    final actionColors = context.skrbActions;

    final rowContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isHidden ? Colors.grey.withAlpha(15) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(40))),
      ),
      child: Opacity(
        opacity: isHidden ? 0.45 : 1.0,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                _displayKey(item.key),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if (item.sublabel != null)
                    Text(
                      item.sublabel!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: item.key == '3'
                  ? DetailSkrbTdpStatus(skrb: skrb, item: item)
                  : Row(
                      children: [
                        Icon(
                          item.isBackgroundProcessing
                              ? Icons.hourglass_top_rounded
                              : (isUploaded
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked),
                          size: 16,
                          color: item.isBackgroundProcessing
                              ? Colors.blue.shade700
                              : (isUploaded ? Colors.green : Colors.grey),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.statusText,
                            style: TextStyle(
                              color: item.isBackgroundProcessing
                                  ? Colors.blue.shade700
                                  : (isUploaded
                                        ? Colors.green.shade700
                                        : Colors.grey),
                              fontWeight:
                                  item.isBackgroundProcessing || isUploaded
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              flex: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: item.isBackgroundProcessing
                    ? Row(
                        key: ValueKey('bg_process_${item.key}'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Membuat Gambar\n(Proses Background...)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : isLoadingThis
                    ? Row(
                        key: ValueKey('loading_${item.key}'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mengunggah...',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Wrap(
                        key: ValueKey('wrap_${item.key}'),
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // KLIEN: Dalam Fase 2 (isLocked == true), icon hide dan tombol upload (Ganti/Pilih File) disembunyikan.
                          // Hanya di Fase 1 dan Fase 3 (isLocked == false) aksi-aksi pengubahan dokumen dimunculkan.
                          if (!isLocked && item.canBeHidden && isUploaded)
                            isHidingThis
                                ? Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isHidden
                                            ? actionColors.hideIcon
                                            : actionColors.unhideIcon,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      isHidden
                                          ? Icons.visibility_off
                                          : Icons.remove_red_eye_outlined,
                                      color: isHidden
                                          ? actionColors.hideIcon
                                          : actionColors.unhideIcon,
                                      size: 18,
                                    ),
                                    tooltip: isHidden
                                        ? 'Aktifkan (Unhide)'
                                        : 'Sembunyikan (Hide dari Merger)',
                                    onPressed: isProcessing
                                        ? null
                                        : () => onToggleHide(item.key, isHidden),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),
                          if (!isLocked && item.isOptionalUpload)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: canUpload
                                    ? (isUploaded
                                          ? actionColors.gantiFileBg
                                          : actionColors.pilihFileBg)
                                    : actionColors.uploadDisabledBg,
                                foregroundColor: canUpload
                                    ? (isUploaded
                                          ? actionColors.gantiFileFg
                                          : actionColors.pilihFileFg)
                                    : actionColors.uploadDisabledFg,
                              ),
                              icon: const Icon(Icons.upload_file, size: 14),
                              label: Text(
                                isUploaded ? 'Ganti File' : 'Pilih File',
                              ),
                              onPressed: canUpload
                                  ? () => onUploadFile(item.key)
                                  : null,
                            ),
                          if (isUploaded)
                            Tooltip(
                              message: isLivePreview
                                  ? 'Preview Versi Terbaru (File Baru)'
                                  : 'Preview Versi Tersimpan',
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  foregroundColor: isLivePreview
                                      ? actionColors.previewLiveFg
                                      : actionColors.previewHistoryFg,
                                  side: BorderSide(
                                    color: isLivePreview
                                        ? actionColors.previewLiveBorder
                                        : actionColors.previewHistoryBorder,
                                    width: isLivePreview ? 1.5 : 1.2,
                                  ),
                                  backgroundColor: isLivePreview
                                      ? actionColors.previewLiveBg
                                      : actionColors.previewHistoryBg,
                                ),
                                icon: const Icon(Icons.visibility, size: 14),
                                label: const Text('Preview Dokumen'),
                                onPressed: isProcessing
                                    ? null
                                    : () => onPreviewPdf(item),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (item.key == '1') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          rowContent,
          DetailSkrbGambarSection(
            skrb: skrb,
            isLocked: isLocked,
            onLiveUpdate: onLiveUpdate ?? () {},
          ),
          DetailSkrbFotoCopyCard(
            skrb: skrb,
            isLocked: isLocked,
            onLiveUpdate: onLiveUpdate ?? () {},
          ),
        ],
      );
    }

    return rowContent;
  }
}
