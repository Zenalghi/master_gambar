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
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        // --- Group Master Data ---
        NavigationRailDestination(
          icon: Icon(Icons.dns),
          label: Text('Type Engine'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bookmark),
          label: Text('Merk'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.directions_car),
          label: Text('Type Chassis'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.fire_truck),
          label: Text('Jenis Kendaraan'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.build),
          label: Text('Varian Body'),
        ),

        // --- TAMBAHKAN ITEM BARU DI SINI ---
        NavigationRailDestination(
          icon: Icon(Icons.category),
          label: Text('Jenis Varian'),
        ),

        // --- Group Master Gambar ---
        NavigationRailDestination(
          icon: Icon(Icons.image),
          label: Text('Gambar Utama'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_photo_alternate),
          label: Text('Gambar Optional'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.electrical_services),
          label: Text('Gambar Kelistrikan'),
        ),
      ],
    );
  }
}
