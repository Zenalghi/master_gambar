//lib\elements\home\home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
// import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';

import '../../admin/screens/configuration_screen.dart';
import '../../admin/screens/master_screen.dart';
import 'providers/input_gambar_providers.dart';
import 'screens/input_gambar_screen.dart';
import 'screens/input_transaksi_screen.dart';
import 'screens/permohonan_skrb_screen.dart';
import 'screens/detail_skrb_screen.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/sidebar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageStateProvider);
    final authService = ref.watch(authServiceProvider);
    final tabCount = authService.canViewAdminTabs() ? 3 : 1;

    Widget currentPage;
    switch (pageState.pageIndex) {
      case 0:
        currentPage = const InputTransaksiScreen();
        break;
      case 1:
        currentPage = InputGambarScreen(transaksi: pageState.data);
        break;
      case 2:
        currentPage = const PermohonanSkrbScreen();
        break;
      case 3:
        currentPage = DetailSkrbScreen(skrbId: pageState.skrbId);
        break;
      default:
        currentPage = const InputTransaksiScreen();
    }

    final List<Widget> tabViews = [
      Row(
        children: [
          Sidebar(
            selectedIndex: pageState.pageIndex,
            onItemSelected: (index) {
              if (pageState.pageIndex == 1 && index == 0) {
                // Jalankan semua logika reset yang Anda berikan
                ref.read(isProcessingProvider.notifier).state = false;
                // ref.read(pemeriksaIdProvider.notifier).state = null;
                ref.read(jumlahGambarProvider.notifier).state = 1;
                ref.invalidate(gambarUtamaSelectionProvider);
                ref.read(deskripsiOptionalProvider.notifier).state = '';
              }

              if (index == 0 || index == 1 || index == 2 || index == 3) {
                if (pageState.pageIndex == 3 && index != 3) {
                  DetailSkrbScreen.checkAndConfirmUnsavedChanges(
                    context,
                    ref,
                  ).then((canProceed) {
                    if (canProceed) {
                      ref.read(pageStateProvider.notifier).state = PageState(
                        pageIndex: index,
                        data: index == 1 ? pageState.data : null,
                      );
                    }
                  });
                } else {
                  ref.read(pageStateProvider.notifier).state = PageState(
                    pageIndex: index,
                    data: index == 1 ? pageState.data : null,
                    skrbId: index == 3 ? pageState.skrbId : null,
                  );
                }
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: currentPage),
        ],
      ),
    ];

    if (authService.canViewAdminTabs()) {
      tabViews.add(const MasterScreen());
      tabViews.add(const ConfigurationScreen());
    }

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
