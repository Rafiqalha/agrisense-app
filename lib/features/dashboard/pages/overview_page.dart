import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_config.dart';
import '../../../models/farmer_dashboard.dart';
import '../../../theme/agrisense_theme.dart';
import '../../../widgets/agrisense_widgets.dart';
import '../view_models.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({
    super.key,
    required this.dashboard,
    required this.onRefresh,
    required this.onOpenFarms,
    required this.onOpenActivity,
    required this.isRefreshing,
    this.syncError,
  });

  final FarmerDashboard dashboard;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenFarms;
  final VoidCallback onOpenActivity;
  final bool isRefreshing;
  final String? syncError;

  @override
  Widget build(BuildContext context) {
    final farms = dashboard.farms.data ?? const <Farm>[];
    final crops = dashboard.crops.data ?? const <Crop>[];
    final harvests = dashboard.harvests.data ?? const <Harvest>[];
    final activities = dashboard.activities.data ?? const <FarmActivity>[];
    final yieldKg = harvests.fold<double>(
      0,
      (total, item) => total + (double.tryParse(item.yieldKg) ?? 0),
    );
    final firstName = dashboard.profile.name.trim().split(RegExp(r'\s+')).first;
    final metrics = [
      _Metric(
        label: 'Kebun',
        value: dashboard.farms.isAvailable ? '${farms.length}' : '—',
        caption: 'lokasi tercatat',
        icon: Icons.eco_outlined,
        tint: AgriColors.green,
        background: AgriColors.softGreen,
      ),
      _Metric(
        label: 'Tanaman aktif',
        value: dashboard.crops.isAvailable
            ? '${crops.where((crop) => crop.status == 'growing').length}'
            : '—',
        caption: 'musim berjalan',
        icon: Icons.spa_outlined,
        tint: AgriColors.green,
        background: AgriColors.softGreen,
      ),
      _Metric(
        label: 'Hasil panen',
        value: dashboard.harvests.isAvailable
            ? _number(yieldKg, maximumFractionDigits: 1)
            : '—',
        caption: 'kg pada daftar',
        icon: Icons.inventory_2_outlined,
        tint: AgriColors.amber,
        background: AgriColors.softAmber,
      ),
      _Metric(
        label: 'Aktivitas',
        value: dashboard.activities.isAvailable ? '${activities.length}' : '—',
        caption: 'catatan terbaru',
        icon: Icons.history_rounded,
        tint: AgriColors.blue,
        background: AgriColors.softBlue,
      ),
    ];

    return RefreshIndicator(
      color: AgriColors.green,
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: const PageStorageKey('overview-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dashboard.dataEnvironment == 'configured_backend'
                              ? 'DATA AKUN ANDA'
                              : 'LINGKUNGAN ${dashboard.dataEnvironment.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.35,
                            color: AgriColors.green,
                          ),
                        ),
                      ),
                      Text(
                        'Diperbarui ${_timeLabel(dashboard.generatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selamat datang,\n$firstName.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Berikut catatan kebun terbaru dari akun WhatsApp Anda.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AgriColors.muted),
                  ),
                  if (syncError != null) ...[
                    const SizedBox(height: 18),
                    _SyncError(message: syncError!),
                  ],
                  const SizedBox(height: 22),
                  _HealthSummary(dashboard: dashboard),
                  const SizedBox(height: 14),
                  _CropHighlight(
                    crops: crops,
                    farms: farms,
                    available: dashboard.crops.isAvailable,
                    onOpenFarms: onOpenFarms,
                  ),
                  const SizedBox(height: 28),
                  const SectionHeading(
                    title: 'Ringkasan kebun',
                    description: 'Jumlah berasal dari catatan yang tersedia.',
                  ),
                  const SizedBox(height: 14),
                  _MetricGrid(metrics: metrics),
                  const SizedBox(height: 28),
                  SectionHeading(
                    title: 'Aktivitas terbaru',
                    description: dashboard.activities.isAvailable
                        ? 'Kegiatan yang telah tersimpan.'
                        : 'Riwayat kegiatan belum dapat dimuat.',
                    action: InlineAction(label: 'Semua', onTap: onOpenActivity),
                  ),
                  const SizedBox(height: 14),
                  _ActivitiesCard(
                    activities: activities,
                    available: dashboard.activities.isAvailable,
                  ),
                  const SizedBox(height: 28),
                  const _SensorAvailabilityCard(),
                  const SizedBox(height: 14),
                  _WhatsAppCard(onTap: () => _openWhatsApp(context)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      isRefreshing
                          ? 'Memperbarui data…'
                          : 'Tarik layar ke bawah untuk memperbarui',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.https('wa.me', '/${AppConfig.whatsAppNumber}');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp belum dapat dibuka.')),
      );
    }
  }
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.dashboard});
  final FarmerDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final partial = dashboard.hasPartialFailure;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: partial ? const Color(0xFF6D4B19) : AgriColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F174F35),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              partial ? Icons.sync_problem_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partial ? 'Sebagian data tertunda' : 'Data utama tersedia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  partial
                      ? 'Data yang berhasil dimuat tetap aman ditampilkan.'
                      : 'Dashboard terhubung dengan catatan AgriSense Anda.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .78),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                StatusPill(
                  label: partial
                      ? 'Perlu sinkronisasi ulang'
                      : 'Tersinkronisasi',
                  status: partial ? AgriStatus.attention : AgriStatus.healthy,
                  small: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropHighlight extends StatelessWidget {
  const _CropHighlight({
    required this.crops,
    required this.farms,
    required this.available,
    required this.onOpenFarms,
  });

  final List<Crop> crops;
  final List<Farm> farms;
  final bool available;
  final VoidCallback onOpenFarms;

  @override
  Widget build(BuildContext context) {
    final growing = crops.where((crop) => crop.status == 'growing').toList();
    if (!available || growing.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              const IconTile(icon: Icons.eco_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  available
                      ? 'Belum ada tanaman aktif yang tercatat.'
                      : 'Data tanaman belum dapat dimuat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final crop = growing.first;
    final farmName = farms
        .where((farm) => farm.id == crop.farmId)
        .map((farm) => farm.name)
        .firstOrNull;
    final harvestDays = crop.expectedHarvestAt
        ?.difference(DateTime.now())
        .inDays
        .clamp(0, 999);
    return Card(
      color: const Color(0xFFFFFBF3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFF0E3C8)),
      ),
      child: InkWell(
        onTap: onOpenFarms,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill(
                      label: 'Sedang tumbuh',
                      status: AgriStatus.healthy,
                      small: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _cropName(crop.cropType),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farmName ?? 'Kebun terkait'} · umur ${crop.ageDays} hari',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (harvestDays != null) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$harvestDays',
                      style: const TextStyle(
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: AgriColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'hari ke panen',
                      style: TextStyle(fontSize: 11, color: AgriColors.muted),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AgriColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});
  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        const gap = 12.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(
                            icon: metric.icon,
                            tint: metric.tint,
                            background: metric.background,
                            size: 38,
                          ),
                          const SizedBox(height: 13),
                          Text(
                            metric.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.value,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActivitiesCard extends StatelessWidget {
  const _ActivitiesCard({required this.activities, required this.available});
  final List<FarmActivity> activities;
  final bool available;

  @override
  Widget build(BuildContext context) {
    if (!available || activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const IconTile(icon: Icons.event_note_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  available
                      ? 'Belum ada aktivitas yang tersimpan.'
                      : 'Aktivitas belum dapat dimuat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final visible = activities.take(2).toList();
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < visible.length; index++) ...[
            _ActivityPreview(activity: visible[index]),
            if (index != visible.length - 1) const Divider(indent: 70),
          ],
        ],
      ),
    );
  }
}

class _ActivityPreview extends StatelessWidget {
  const _ActivityPreview({required this.activity});
  final FarmActivity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: _activityIcon(activity.activityType)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activityName(activity.activityType),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _shortDate(activity.performedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SensorAvailabilityCard extends StatelessWidget {
  const _SensorAvailabilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgriColors.softBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E5F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconTile(
            icon: Icons.sensors_off_outlined,
            tint: AgriColors.blue,
            background: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sensor lapangan belum terhubung',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Suhu, kelembapan, dan pH baru akan tampil setelah layanan sensor tersedia di backend AgriSense.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppCard extends StatelessWidget {
  const _WhatsAppCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AgriColors.softGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6D9)),
      ),
      child: Row(
        children: [
          const IconTile(icon: Icons.chat_outlined, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat kegiatan lewat WhatsApp',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Catatan baru akan muncul saat dashboard diperbarui.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            tooltip: 'Buka WhatsApp',
            style: IconButton.styleFrom(
              backgroundColor: AgriColors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_outward_rounded),
          ),
        ],
      ),
    );
  }
}

class _SyncError extends StatelessWidget {
  const _SyncError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AgriColors.softAmber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded, color: AgriColors.amber),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$message Data terakhir tetap ditampilkan.',
              style: const TextStyle(color: AgriColors.amber, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.tint,
    required this.background,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color tint;
  final Color background;
}

String _timeLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour.$minute WIB';
}

String _number(double value, {int maximumFractionDigits = 0}) {
  final fixed = value.toStringAsFixed(maximumFractionDigits);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  if (parts.length == 2 && int.tryParse(parts[1]) != 0) {
    buffer.write(',${parts[1]}');
  }
  return buffer.toString();
}

String _cropName(String type) => switch (type.toLowerCase()) {
  'melon' => 'Melon',
  'rice' => 'Padi',
  'corn' => 'Jagung',
  'tomato' => 'Tomat',
  'chili' => 'Cabai',
  _ => type,
};

String _activityName(String type) => switch (type.toLowerCase()) {
  'watering' => 'Penyiraman',
  'fertilizing' => 'Pemupukan',
  'spraying' => 'Penyemprotan',
  'pruning' => 'Pemangkasan',
  'inspection' => 'Pemeriksaan',
  _ => type,
};

IconData _activityIcon(String type) => switch (type.toLowerCase()) {
  'watering' => Icons.water_drop_outlined,
  'fertilizing' => Icons.grass_outlined,
  'spraying' => Icons.air_rounded,
  'pruning' => Icons.content_cut_rounded,
  _ => Icons.fact_check_outlined,
};

String _shortDate(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  if (day == today) return 'Hari ini';
  if (day == today.subtract(const Duration(days: 1))) return 'Kemarin';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${local.day} ${months[local.month - 1]}';
}
