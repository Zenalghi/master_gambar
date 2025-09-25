import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/notifiers/refresh_notifier.dart';

class GlobalRefreshButton extends ConsumerWidget {
  const GlobalRefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: 'Refresh Master Data',
      onPressed: () {
        // Bunyikan "lonceng" dengan memanggil method refresh
        ref.read(refreshNotifierProvider.notifier).refresh();

        // Beri feedback visual ke pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memuat ulang data master...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
