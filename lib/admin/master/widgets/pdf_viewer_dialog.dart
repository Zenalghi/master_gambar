import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerDialog extends StatefulWidget {
  final Uint8List pdfData;
  final String title;

  const PdfViewerDialog({
    super.key,
    required this.pdfData,
    this.title = 'PDF Viewer',});

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  late final PdfController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfData),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.all(8.0),
      // Make the dialog large to properly view the PDF
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 24.0,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: PdfView(
          controller: _pdfController,
          scrollDirection: Axis.vertical,
          onDocumentLoaded: (document) {
            setState(() {
              _totalPages = document.pagesCount;
            });
          },
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              tooltip: 'Halaman Sebelumnya',
              onPressed: _currentPage > 1
                  ? () => _pdfController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
            const SizedBox(width: 4),
            Text(
              _totalPages > 0
                  ? 'Page $_currentPage of $_totalPages'
                  : 'Memuat...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              tooltip: 'Halaman Berikutnya',
              onPressed: _currentPage < _totalPages
                  ? () => _pdfController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ],
    );
  }
}
