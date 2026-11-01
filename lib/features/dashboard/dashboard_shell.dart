import 'package:flutter/material.dart';

import '../../models/farmer_dashboard.dart';
import '../../theme/agrisense_theme.dart';
import '../../widgets/agrisense_widgets.dart';
import 'pages/activity_page.dart';
import 'pages/farms_page.dart';
import 'pages/overview_page.dart';
import 'pages/profile_page.dart';
import 'view_models.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({
    super.key,
    required this.dashboard,
    required this.onRefresh,
    required this.onLogout,
    required this.isRefreshing,
    this.syncError,
  });

  final FarmerDashboard dashboard;
  final Future<void> Function() onRefresh;
  final Future<void> Function({String? message}) onLogout;
  final bool isRefreshing;
  final String? syncError;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _NotificationSheet(dashboard: widget.dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      OverviewPage(
        dashboard: widget.dashboard,
        isRefreshing: widget.isRefreshing,
        syncError: widget.syncError,
        onRefresh: widget.onRefresh,
        onOpenFarms: () => _select(1),
        onOpenActivity: () => _select(2),
      ),
      FarmsPage(dashboard: widget.dashboard),
      ActivityPage(activities: widget.dashboard.activities),
      ProfilePage(dashboard: widget.dashboard, onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                color: AgriColors.surface,
                border: Border(bottom: BorderSide(color: AgriColors.line)),
              ),
              child: Row(
                children: [
                  const BrandMark(),
                  const Spacer(),
                  if (widget.isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Semantics(
                    button: true,
                    label: widget.dashboard.hasPartialFailure
                        ? 'Buka pemberitahuan, ada data yang belum tersedia'
                        : 'Buka pemberitahuan',
                    child: IconButton(
                      onPressed: _showNotifications,
                      tooltip: 'Pemberitahuan',
                      style: IconButton.styleFrom(
                        backgroundColor: AgriColors.canvas,
                        minimumSize: const Size(46, 46),
                      ),
                      icon: Badge(
                        isLabelVisible: widget.dashboard.hasPartialFailure,
                        backgroundColor: AgriColors.amber,
                        smallSize: 7,
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AgriColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AgriColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: 'Ringkasan',
            ),
            NavigationDestination(
              icon: Icon(Icons.eco_outlined),
              selectedIcon: Icon(Icons.eco_rounded),
              label: 'Kebun',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_toggle_off_rounded),
              label: 'Aktivitas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet({required this.dashboard});

  final FarmerDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final partial = dashboard.hasPartialFailure;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Pemberitahuan',
            description: 'Status sinkronisasi data kebun Anda.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconTile(
                    icon: partial
                        ? Icons.cloud_off_outlined
                        : Icons.cloud_done_outlined,
                    tint: partial ? AgriColors.amber : AgriColors.green,
                    background: partial
                        ? AgriColors.softAmber
                        : AgriColors.softGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partial
                              ? 'Sebagian data belum tersedia'
                              : 'Data kebun tersinkronisasi',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          partial
                              ? 'Data yang berhasil dimuat tetap ditampilkan. Tarik layar untuk mencoba kembali.'
                              : 'Dashboard menampilkan catatan terbaru dari akun WhatsApp Anda.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 9),
                        StatusPill(
                          label: partial ? 'Perlu diperiksa' : 'Tersambung',
                          status: partial
                              ? AgriStatus.attention
                              : AgriStatus.healthy,
                          small: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }
}
