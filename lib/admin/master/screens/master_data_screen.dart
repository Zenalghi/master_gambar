// File: lib/admin/master/screens/master_data_screen.dart

import 'package:flutter/material.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manajemen Master Data (Rakitan)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Nanti di sini akan ada form 4 dropdown
          // dan tabel Master Data
          Center(child: Text('Halaman ini sedang dalam pengembangan.')),
        ],
      ),
    );
  }
}
