// File: lib/elements/home/widgets/gambar/gambar_kelistrikan_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarKelistrikanSection extends ConsumerWidget {
  final Transaksi transaksi;
  final int pageNumber;
  final int totalHalaman;
  final VoidCallback onPreviewPressed;

  const GambarKelistrikanSection({
    super.key,
    required this.transaksi,
    required this.pageNumber,
    required this.totalHalaman,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);
    final isLoadingData = ref.watch(isLoadingKelistrikanProvider);
    final selectedId = ref.watch(selectedKelistrikanIdProvider);

    final pihakPenyetujuan = ref.watch(pihakPenyetujuanProvider);
    final bool isPemeriksaValid =
        pihakPenyetujuan == 'customer' ||
        ref.watch(pemeriksaIdProvider) != null;

    final String statusCode = kelistrikanInfo?['status_code'] ?? 'loading';
    final String displayText = kelistrikanInfo?['display_text'] ?? 'Memuat...';
    final List<dynamic> options = kelistrikanInfo?['options'] ?? [];

    final bool isReady =
        !isLoadingData &&
        (statusCode == 'ready' || statusCode == 'multiple_options');

    // --- UPDATE LOGIKA ENABLE BUTTON ---
    final bool isPreviewEnabled =
        isReady && selectedId != null && isPemeriksaValid;
    // -----------------------------------

    final bool isProcessing = ref.watch(isProcessingProvider);
    final bool isEditMode = ref.watch(isEditModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final badgeContainerColor = scheme.brightness == Brightness.dark
        ? const Color(0xFF5A4700)
        : const Color(0xFFFFF3B0);
    final badgeTextColor = scheme.brightness == Brightness.dark
        ? const Color(0xFFFFF4C7)
        : Colors.black87;

    final bgColor = isReady
        ? scheme.surfaceContainerHighest
        : (isLoadingData ? scheme.surfaceContainerLow : scheme.errorContainer);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Gambar Kelistrikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Gambar Kelistrikan:',
                  style: TextStyle(color: scheme.onSurface),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: isReady
                      ? Border.all(color: scheme.outlineVariant)
                      : Border.all(color: scheme.error),
                ),
                child: isLoadingData
                    ? const SizedBox(
                        height: 24,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _buildContent(
                        context,
                        ref,
                        statusCode,
                        displayText,
                        options,
                        selectedId,
                        isEditMode,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isReady
                          ? badgeContainerColor
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        isReady ? '$pageNumber/$totalHalaman' : '-/-',
                        style: TextStyle(
                          color: isReady
                              ? badgeTextColor
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 170,
                  child: ElevatedButton(
                    onPressed: isPreviewEnabled && !isProcessing
                        ? onPreviewPressed
                        : null,
                    child: const Text('Preview Gambar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String statusCode,
    String displayText,
    List<dynamic> options,
    int? selectedId,
    bool isEditMode,
  ) {
    final scheme = Theme.of(context).colorScheme;

    if (statusCode == 'ready') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(displayText, style: TextStyle(color: scheme.onSurface)),
      );
    }

    if (statusCode == 'multiple_options') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                displayText,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Pilih salah satu deskripsi kelistrikan yang sesuai',
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RadioGroup<int>(
            groupValue: selectedId,
            onChanged: (val) {
              if (!isEditMode) return;
              ref.read(selectedKelistrikanIdProvider.notifier).state = val;
            },
            child: Column(
              children: options.map((opt) {
                final int optId = opt['id'];
                final String optDesc = opt['deskripsi'];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  leading: Radio<int>(
                    value: optId,
                    activeColor: scheme.primary,
                  ),
                  title: Text(
                    optDesc,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return Text(
      displayText,
      style: TextStyle(
        color: scheme.onErrorContainer,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
