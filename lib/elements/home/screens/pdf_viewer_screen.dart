import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerScreen extends StatefulWidget {
  final Uint8List pdfData;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfData,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data PDF dari byte
    _pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PdfView(controller: _pdfController),
    );
  }
}
