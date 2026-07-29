// lib/admin/management/widgets/document/components/card_format_penomoran.dart
import 'package:flutter/material.dart';

import 'shared_widgets.dart';

/// Card 4 – Format Penomoran Permohonan.
class CardFormatPenomoran extends StatelessWidget {
  final bool isAdmin;
  final ColorScheme colorScheme;
  final TextEditingController skrbCtrl;
  final TextEditingController rekomCtrl;
  final TextEditingController alamatPermohonanCtrl;
  final TextEditingController bidangUsahaCtrl;
  final TextEditingController alamatLengkapCtrl;

  const CardFormatPenomoran({
    super.key,
    required this.isAdmin,
    required this.colorScheme,
    required this.skrbCtrl,
    required this.rekomCtrl,
    required this.alamatPermohonanCtrl,
    required this.bidangUsahaCtrl,
    required this.alamatLengkapCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Format Penomoran Permohonan :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                // const RequiredBadge(),
              ],
            ),
            const SizedBox(height: 12),
            LabeledTextField(
              label: 'Permohonan SKRB',
              controller: skrbCtrl,
              isAdmin: isAdmin,
            ),
            const SizedBox(height: 8),
            LabeledTextField(
              label: 'Permohonan Rekom',
              controller: rekomCtrl,
              isAdmin: isAdmin,
            ),
            const SizedBox(height: 8),
            LabeledTextField(
              label: 'Alamat Permohonan',
              controller: alamatPermohonanCtrl,
              isAdmin: isAdmin,
            ),
            const SizedBox(height: 8),
            LabeledTextField(
              label: 'Bidang Usaha',
              controller: bidangUsahaCtrl,
              isAdmin: isAdmin,
            ),
            const SizedBox(height: 8),
            LabeledTextField(
              label: 'Alamat Lengkap',
              controller: alamatLengkapCtrl,
              isAdmin: isAdmin,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
