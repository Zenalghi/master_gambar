// File: lib/elements/home/widgets/detail_skrb/detail_skrb_pdf_preview.dart
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class DetailSkrbPdfPreview extends StatelessWidget {
  final bool showPdfCard;
  final bool isLoadingPdf;
  final String? pdfCardTitle;
  final List<PdfController> pdfControllers;
  final VoidCallback onClose;

  const DetailSkrbPdfPreview({
    super.key,
    required this.showPdfCard,
    required this.isLoadingPdf,
    required this.pdfCardTitle,
    required this.pdfControllers,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!showPdfCard || (!isLoadingPdf && pdfControllers.isEmpty)) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      flex: 6,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  const SizedBox(width: 1),
                  Expanded(
                    child: Text(
                      pdfCardTitle ?? 'Preview Dokumen PDF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Tutup Preview',
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: isLoadingPdf
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 2),
                            Text(
                              'Memuat dokumen preview...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : pdfControllers.length == 1
                    ? PdfView(controller: pdfControllers.first)
                    : ListView.builder(
                        padding: const EdgeInsets.all(1),
                        itemCount: pdfControllers.length,
                        itemBuilder: (context, idx) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    'Dokumen TDP ke-${idx + 1} (dari total ${pdfControllers.length} file)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 600,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withAlpha(60),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: PdfView(
                                    controller: pdfControllers[idx],
                                  ),
                                ),
                              ),
                            ),
                            if (idx < pdfControllers.length - 1)
                              const SizedBox(height: 2),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
