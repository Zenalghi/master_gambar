// File: lib/admin/master/screens/master_type_chassis_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../widgets/c-chassis/type_chassis_form_card.dart';
import '../widgets/c-chassis/type_chassis_table.dart';
import '../providers/master_data_providers.dart';
import '../widgets/recycle_bin/type_chassis_recycle_bin.dart';

class MasterTypeChassisScreen extends ConsumerStatefulWidget {
  const MasterTypeChassisScreen({super.key});
  @override
  ConsumerState<MasterTypeChassisScreen> createState() =>
      _MasterTypeChassisScreenState();
}

class _MasterTypeChassisScreenState
    extends ConsumerState<MasterTypeChassisScreen> {
  @override
  void initState() {
    super.initState();
    // --- RESET SEARCH & FILTER TYPE CHASSIS ---
    Future.microtask(() => ref.invalidate(typeChassisFilterProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              const Text(
                'Manajemen Type Chassis',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Search Field
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Search Type Chassis...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => {...state, 'search': ''});
                },
              ),
              const SizedBox(width: 8),
              // Recycle Bin Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin (Data Dihapus)',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const TypeChassisRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          // Form Input
          const TypeChassisFormCard(),
          const SizedBox(height: 5),
          const Expanded(child: TypeChassisTable()),
        ],
      ),
    );
  }
}
