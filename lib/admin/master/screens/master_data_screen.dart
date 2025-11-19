import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/add_master_data_form.dart';
import '../widgets/master_data_table.dart';
import '../providers/master_data_providers.dart';

class MasterDataScreen extends ConsumerWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Master Data (Kombinasi)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => ref
                      .read(masterDataFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref
                    .read(masterDataFilterProvider.notifier)
                    .update((state) => Map.from(state)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AddMasterDataForm(),
          const SizedBox(height: 16),
          const Expanded(child: MasterDataTable()),
        ],
      ),
    );
  }
}
