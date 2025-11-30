// File: lib/elements/home/widgets/sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      minWidth: 1,
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.table_rows_rounded, size: 21),
          label: Text(
            'Transaksi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.image, size: 21),
          label: Text(
            'Input\nGambar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
