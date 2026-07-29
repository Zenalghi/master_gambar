// lib/admin/management/widgets/document/components/action_buttons_bar.dart
import 'package:flutter/material.dart';

/// Row tombol aksi di bagian bawah form dokumen:
/// [Batal Edit] [Hapus] [Simpan]
class ActionButtonsBar extends StatelessWidget {
  final bool isAdmin;
  final bool hasExistingDoc;
  final bool hasChanges;
  final bool isAllFilled;
  final bool isSaving;
  final ColorScheme colorScheme;
  final VoidCallback onCancelEdit;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const ActionButtonsBar({
    super.key,
    required this.isAdmin,
    required this.hasExistingDoc,
    required this.hasChanges,
    required this.isAllFilled,
    required this.isSaving,
    required this.colorScheme,
    required this.onCancelEdit,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final canSave = hasChanges && isAllFilled && !isSaving;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (hasExistingDoc) ...[
                // Batal Edit
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancelEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text(
                      'Batal Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Hapus
                if (isAdmin) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
              // Simpan
              if (isAdmin)
                Expanded(
                  child: Tooltip(
                    message: !isAllFilled
                        ? 'Harus melengkapi semua field wajib (Kop Surat, Data Umum, TDP 1, Masa Berlaku, & Format Penomoran) sebelum menyimpan.'
                        : '',
                    child: ElevatedButton.icon(
                      onPressed: canSave ? onSave : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: (hasChanges && isAllFilled)
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        foregroundColor: (hasChanges && isAllFilled)
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 16),
                      label: Text(
                        isSaving ? 'Menyimpan...' : 'Simpan',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
