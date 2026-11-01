import 'package:flutter/material.dart';

import '../../../models/farmer_dashboard.dart';
import '../../../theme/agrisense_theme.dart';
import '../../../widgets/agrisense_widgets.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.activities});

  final ReadSection<List<FarmActivity>> activities;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final allActivities = widget.activities.data ?? const <FarmActivity>[];
    final types =
        allActivities.map((item) => item.activityType).toSet().toList()..sort();
    final activities = allActivities
        .where((item) => _filter.isEmpty || item.activityType == _filter)
        .toList();

    return CustomScrollView(
      key: const PageStorageKey('activity-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivitas',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 7),
                Text(
                  'Riwayat kegiatan yang sudah tersimpan.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AgriColors.muted),
                ),
                const SizedBox(height: 20),
                if (types.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Semua'),
                            selected: _filter.isEmpty,
                            onSelected: (_) => setState(() => _filter = ''),
                          ),
                        ),
                        ...types.map(
                          (type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_activityName(type)),
                              selected: _filter == type,
                              onSelected: (_) => setState(() => _filter = type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      children: [
                        const IconTile(
                          icon: Icons.query_stats_rounded,
                          tint: AgriColors.blue,
                          background: AgriColors.softBlue,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.activities.isAvailable
                                    ? '${allActivities.length} kegiatan ditampilkan'
                                    : 'Aktivitas belum tersedia',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Maksimal 20 catatan terbaru',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SectionHeading(
                  title: 'Riwayat terbaru',
                  description: '${activities.length} catatan ditampilkan',
                ),
                const SizedBox(height: 16),
                if (!widget.activities.isAvailable)
                  const _UnavailableActivity()
                else if (activities.isEmpty)
                  _EmptyActivity(filtered: _filter.isNotEmpty)
                else
                  _ActivityTimeline(activities: activities),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.activities});
  final List<FarmActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        final last = index == activities.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 46,
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AgriColors.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _activityIcon(activity.activityType),
                        color: AgriColors.green,
                        size: 19,
                      ),
                    ),
                    if (!last)
                      Expanded(
                        child: Container(width: 1, color: AgriColors.line),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _activityName(activity.activityType),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              Text(
                                _timeLabel(activity.performedAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            activity.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (activity.quantity != null) ...[
                            const SizedBox(height: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AgriColors.softGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${activity.quantity} ${activity.unit ?? ''}'
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AgriColors.green,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          Text(
                            _dateLabel(activity.performedAt),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AgriColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _UnavailableActivity extends StatelessWidget {
  const _UnavailableActivity();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const IconTile(
              icon: Icons.cloud_off_outlined,
              tint: AgriColors.amber,
              background: AgriColors.softAmber,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              'Aktivitas belum dapat dimuat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              'Tarik halaman Ringkasan untuk mencoba kembali.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const IconTile(icon: Icons.event_note_outlined, size: 52),
            const SizedBox(height: 14),
            Text(
              filtered
                  ? 'Tidak ada kegiatan pada kategori ini'
                  : 'Belum ada aktivitas tercatat',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              filtered ? 'Pilih Semua untuk melihat catatan lainnya.' : 'Kegiatan yang disimpan melalui WhatsApp akan tampil di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

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

String _timeLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}.${local.minute.toString().padLeft(2, '0')} WIB';
}

String _dateLabel(DateTime value) {
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
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
