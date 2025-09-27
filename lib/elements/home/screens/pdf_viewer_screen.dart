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
  late final TransformationController _transformationController;

  double _currentZoom = 1.0;
  final double _maxZoom = 5.0;
  final double _minZoom = 0.25;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfData),
    );
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final newZoom = _transformationController.value.getMaxScaleOnAxis();
    // Gunakan toleransi kecil untuk menghindari update berulang
    if ((_currentZoom - newZoom).abs() > 0.001) {
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  // --- FUNGSI ZOOM BARU YANG LEBIH PINTAR ---
  void _setZoom(double zoom) {
    final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    if (clampedZoom == _currentZoom) return; // Hindari operasi jika zoom sama

    // Ambil ukuran viewport (area yang terlihat)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final center = Offset(screenWidth / 2, screenHeight / 2);

    // Dapatkan matrix saat ini
    final currentMatrix = _transformationController.value;
    // Dapatkan scale saat ini dari matrix
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    // Hitung rasio scale yang dibutuhkan
    final scaleRatio = clampedZoom / currentScale;

    // Buat matrix baru dengan mengalikan matrix saat ini
    // dengan transformasi scale yang berpusat di tengah layar
    final newMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scaleRatio)
      ..translate(-center.dx, -center.dy);

    _transformationController.value = newMatrix * currentMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            maxScale: _maxZoom,
            minScale: _minZoom,
            // --- PASTIKAN PAN & SCALE AKTIF ---
            panEnabled: true,
            scaleEnabled: true,
            child: PdfView(controller: _pdfController),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildZoomControls()),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () => _setZoom(_currentZoom - 0.2),
          ),
          Expanded(
            child: Slider(
              value: _currentZoom,
              min: _minZoom,
              max: _maxZoom,
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              onChanged: (value) {
                _setZoom(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () => _setZoom(_currentZoom + 0.2),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${(_currentZoom * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
