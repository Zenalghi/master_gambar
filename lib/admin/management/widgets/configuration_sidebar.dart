import 'package:flutter/material.dart';

class ConfigurationSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ConfigurationSidebar({
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
        NavigationRailDestination(
          icon: Icon(Icons.business),
          label: Text('Customer'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('User'),
        ),
      ],
    );
  }
}
