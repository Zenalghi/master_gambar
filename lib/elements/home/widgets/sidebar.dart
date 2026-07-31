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
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.64);

    return Container(
      width: 86,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildNavItem(
            index: 0,
            icon: Icons.table_rows_rounded,
            label: 'Transaksi',
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            enabled: true,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.image,
            label: 'Input\nGambar',
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            enabled: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Divider(thickness: 1, height: 16),
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.assignment_turned_in_outlined,
            activeIcon: Icons.assignment_turned_in,
            label: 'Permohonan\nSKRB',
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            enabled: true,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Detail\nSKRB',
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
    required bool enabled,
    Color? overrideUnselectedColor,
    VoidCallback? onDisabledTap,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? selectedColor
        : (enabled
              ? unselectedColor
              : (overrideUnselectedColor ?? unselectedColor));

    return InkWell(
      onTap: () {
        if (!enabled && onDisabledTap != null) {
          onDisabledTap();
          return;
        }
        if (enabled && !isSelected) {
          onItemSelected(index);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
