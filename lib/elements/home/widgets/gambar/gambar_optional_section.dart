// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

// class GambarOptionalSection extends ConsumerWidget {
//   final int totalHalaman;
//   // --- PERUBAHAN 1: Callback sekarang hanya menerima index ---
//   final Function(int index) onPreviewPressed;
//   final int basePageNumber; // Kita masih perlu ini untuk ditampilkan di UI

//   const GambarOptionalSection({
//     super.key,
//     required this.totalHalaman,
//     required this.onPreviewPressed,
//     required this.basePageNumber,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final jumlah = ref.watch(jumlahGambarOptionalProvider);

//     // ref.listen<int>(jumlahGambarOptionalProvider, (prev, next) {
//     //   ref.read(gambarOptionalSelectionProvider.notifier).resize(next);
//     // });

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildJumlahDropdown(ref),
//         const SizedBox(height: 8),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: jumlah,
//           itemBuilder: (context, index) {
//             // --- PERUBAHAN 2: Panggil callback hanya dengan index ---
//             return _GambarOptionalRow(
//               index: index,
//               pageNumber: basePageNumber + index, // Untuk tampilan
//               totalHalaman: totalHalaman,
//               onPreviewPressed: () =>
//                   onPreviewPressed(index), // Kirim index (0, 1, 2, ...)
//             );
//           },
//           separatorBuilder: (context, index) => const SizedBox(height: 8),
//         ),
//       ],
//     );
//   }

//   Widget _buildJumlahDropdown(WidgetRef ref) {
//     return Row(
//       children: [
//         const SizedBox(width: 150, child: Text('Jumlah Gambar Optional:')),
//         SizedBox(
//           width: 100,
//           child: DropdownButtonFormField<int>(
//             value: ref.watch(jumlahGambarOptionalProvider),
//             decoration: const InputDecoration(border: OutlineInputBorder()),
//             items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
//                 .map(
//                   (e) => DropdownMenuItem(value: e, child: Text(e.toString())),
//                 )
//                 .toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 ref.read(jumlahGambarOptionalProvider.notifier).state = value;
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Widget privat untuk satu baris
// class _GambarOptionalRow extends ConsumerWidget {
//   final int index;
//   final int pageNumber;
//   final int totalHalaman;
//   final VoidCallback onPreviewPressed;

//   const _GambarOptionalRow({
//     required this.index,
//     required this.pageNumber,
//     required this.totalHalaman,
//     required this.onPreviewPressed,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pemeriksaId = ref.watch(pemeriksaIdProvider);
//     final optionsAsync = ref.watch(gambarOptionalOptionsProvider);
//     final selection = ref.watch(gambarOptionalSelectionProvider)[index];
//     final isLoading = ref.watch(isProcessingProvider);
//     return Row(
//       children: [
//         const SizedBox(width: 150, child: Text('Gambar Optional:')),
//         Expanded(
//           child: optionsAsync.when(
//             data: (items) {
//               // --- PERBAIKAN PENTING DI SINI ---

//               // 1. Cek apakah ID yang tersimpan (selection.gambarOptionalId)
//               //    benar-benar ada di daftar items yang baru dimuat.
//               final bool valueExists = items.any(
//                 (e) => e.id == selection.gambarOptionalId,
//               );

//               // 2. Jika tidak ada, paksa jadi null agar Dropdown tidak crash (Merah)
//               final int? validValue = valueExists
//                   ? selection.gambarOptionalId
//                   : null;

//               // 3. (Opsional) Jika data hilang, update state agar sinkron
//               if (selection.gambarOptionalId != null && !valueExists) {
//                 // Gunakan microtask agar tidak error saat build
//                 Future.microtask(() {
//                   ref
//                       .read(gambarOptionalSelectionProvider.notifier)
//                       .updateSelection(index, gambarOptionalId: null);
//                 });
//               }

//               final isSelected = validValue != null && pemeriksaId != null;

//               return Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<int>(
//                       itemHeight: 30,
//                       value: validValue, // Gunakan nilai yang sudah divalidasi
//                       decoration: InputDecoration(
//                         constraints: const BoxConstraints(maxHeight: 50),
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical:
//                               9, // Padding vertikal kecil agar teks pas tengah
//                           horizontal: 10,
//                         ),
//                         hintText: 'Pilih Gambar Optional ${index + 1}',
//                         border: const OutlineInputBorder(),
//                         isDense: true, // Padatkan layout
//                       ),
//                       items: items
//                           .map(
//                             (e) => DropdownMenuItem<int>(
//                               value: e.id as int,
//                               child: Text(
//                                 e.name,
//                                 style: const TextStyle(fontSize: 12),
//                                 overflow: TextOverflow
//                                     .ellipsis, // Cegah overflow teks panjang
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (value) => ref
//                           .read(gambarOptionalSelectionProvider.notifier)
//                           .updateSelection(index, gambarOptionalId: value),
//                     ),
//                   ),

//                   const SizedBox(width: 8),

//                   // Indikator Halaman
//                   SizedBox(
//                     width: 70,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.yellow.shade200,
//                         borderRadius: BorderRadius.circular(4),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Center(child: Text('$pageNumber/$totalHalaman')),
//                     ),
//                   ),

//                   const SizedBox(width: 8),

//                   // Tombol Preview
//                   SizedBox(
//                     width: 170,
//                     child: ElevatedButton(
//                       onPressed: isSelected && !isLoading
//                           ? onPreviewPressed
//                           : null,
//                       child: const Text('Preview Gambar'),
//                     ),
//                   ),
//                 ],
//               );
//             },
//             loading: () => const Center(
//               child: SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             ),
//             error: (err, stack) => const Text('Error memuat opsi'),
//           ),
//         ),
//       ],
//     );
//   }
// }
