// File: lib/admin/master/widgets/master_sidebar.dart

import 'package:flutter/material.dart';

class MasterSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MasterSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan lebar sidebar
    return SizedBox(
      width: 220,
      // Gunakan Drawer untuk mendapatkan style latar belakang dan elevasi yang konsisten
      child: Drawer(
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // --- KATEGORI 1: MASTER DATA ---
            ExpansionTile(
              title: const Text(
                'Master Data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              initiallyExpanded: true, // Default expand sesuai permintaan
              childrenPadding: const EdgeInsets.only(left: 16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.dns),
                  title: const Text('Type Engine'),
                  selected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Merk'),
                  selected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                ListTile(
                  leading: const Icon(Icons.fire_truck_rounded),
                  title: const Text('Type Chassis'),
                  selected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: const Text('Jenis Kendaraan'),
                  selected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
                ListTile(
                  leading: const Icon(Icons.dataset_linked_rounded),
                  title: const Text('Master Data'),
                  selected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                ),
                ListTile(
                  leading: const Icon(Icons.category_sharp),
                  title: const Text('Varian Body'),
                  selected: selectedIndex == 5,
                  onTap: () => onItemSelected(5),
                ),
                ListTile(
                  leading: const Icon(Icons.title_outlined),
                  title: const Text('Jenis Varian'),
                  selected: selectedIndex == 6,
                  onTap: () => onItemSelected(6),
                ),
              ],
            ),

            const Divider(),

            // --- KATEGORI 2: MASTER GAMBAR ---
            ExpansionTile(
              title: const Text(
                'Master Gambar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              initiallyExpanded: true, // Default expand sesuai permintaan
              childrenPadding: const EdgeInsets.only(left: 16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Laporan Status Gambar'),
                  selected: selectedIndex == 7,
                  onTap: () => onItemSelected(7),
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Gambar Utama'),
                  selected: selectedIndex == 8,
                  onTap: () => onItemSelected(8),
                ),
                ListTile(
                  leading: const Icon(Icons.add_photo_alternate_outlined),
                  title: const Text('Gambar Optional'),
                  selected: selectedIndex == 9,
                  onTap: () => onItemSelected(9),
                ),
                ListTile(
                  leading: const Icon(Icons.electrical_services_outlined),
                  title: const Text('Gambar Kelistrikan'),
                  selected: selectedIndex == 10,
                  onTap: () => onItemSelected(10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
