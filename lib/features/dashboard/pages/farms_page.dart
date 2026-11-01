import 'package:flutter/material.dart';

import '../../../models/farmer_dashboard.dart';
import '../../../theme/agrisense_theme.dart';
import '../../../widgets/agrisense_widgets.dart';
import '../view_models.dart';

class FarmsPage extends StatefulWidget {
  const FarmsPage({super.key, required this.dashboard});

  final FarmerDashboard dashboard;

  @override
  State<FarmsPage> createState() => _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allFarms = widget.dashboard.farms.data ?? const <Farm>[];
    final crops = widget.dashboard.crops.data ?? const <Crop>[];
    final farms = allFarms.where((farm) {
      final cropText = crops
          .where((crop) => crop.farmId == farm.id)
          .map((crop) => '${crop.cropType} ${crop.seedVariety ?? ''}')
          .join(' ');
      return '${farm.name} ${farm.soilType ?? ''} $cropText'
          .toLowerCase()
          .contains(_query.toLowerCase());
    }).toList();
    final totalArea = allFarms.fold<double>(
      0,
      (total, farm) => total + (double.tryParse(farm.areaHectares ?? '') ?? 0),
    );

    return CustomScrollView(
      key: const PageStorageKey('farms-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebun', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 7),
                Text(
                  'Pantau tanaman yang tercatat di setiap lokasi.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AgriColors.muted),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Cari kebun atau tanaman',
                    semanticCounterText: 'Cari kebun',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        label: 'Kebun tercatat',
                        value: widget.dashboard.farms.isAvailable
                            ? '${allFarms.length}'
                            : '—',
                        icon: Icons.eco_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryBox(
                        label: 'Total area',
                        value: widget.dashboard.farms.isAvailable
                            ? '${_decimal(totalArea)} ha'
                            : '—',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeading(
                  title: 'Daftar kebun',
                  description: widget.dashboard.farms.isAvailable
                      ? '${farms.length} lokasi ditampilkan'
                      : 'Data kebun belum dapat dimuat',
                ),
                const SizedBox(height: 14),
                if (!widget.dashboard.farms.isAvailable)
                  const _UnavailableCard()
                else if (farms.isEmpty)
                  _NoFarmResult(hasQuery: _query.isNotEmpty)
                else
                  ...farms.map(
                    (farm) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FarmCard(
                        farm: farm,
                        crops: crops
                            .where((crop) => crop.farmId == farm.id)
                            .toList(),
                        onTap: () => _showFarmDetails(
                          context,
                          farm,
                          crops
                              .where((crop) => crop.farmId == farm.id)
                              .toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFarmDetails(BuildContext context, Farm farm, List<Crop> crops) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        maxChildSize: .92,
        minChildSize: .55,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          children: [
            Row(
              children: [
                const IconTile(icon: Icons.eco_outlined, size: 48),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${farm.activeCropCount} tanaman aktif',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionHeading(title: 'Rincian kebun'),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Luas lahan',
              value: farm.areaHectares == null
                  ? 'Belum tercatat'
                  : '${_decimal(double.parse(farm.areaHectares!))} ha',
            ),
            _DetailRow(
              label: 'Jenis tanah',
              value: farm.soilType ?? 'Belum tercatat',
            ),
            _DetailRow(
              label: 'Irigasi',
              value: farm.irrigationType ?? 'Belum tercatat',
            ),
            const SizedBox(height: 22),
            SectionHeading(
              title: 'Tanaman',
              description: '${crops.length} musim tanam ditampilkan',
            ),
            const SizedBox(height: 12),
            if (!widget.dashboard.crops.isAvailable)
              const _UnavailableCard()
            else if (crops.isEmpty)
              const _EmptyCrops()
            else
              ...crops.map(
                (crop) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CropCard(crop: crop),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AgriColors.softBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sensors_off_outlined,
                    color: AgriColors.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data sensor belum tersedia pada API kebun. Aplikasi tidak menampilkan angka perkiraan.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AgriColors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AgriColors.green),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  const _FarmCard({
    required this.farm,
    required this.crops,
    required this.onTap,
  });
  final Farm farm;
  final List<Crop> crops;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final growing = crops.where((crop) => crop.status == 'growing').toList();
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconTile(icon: Icons.eco_outlined, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                                farm.soilType,
                                farm.irrigationType,
                              ].whereType<String>().join(' · ').isEmpty
                              ? 'Rincian lahan belum lengkap'
                              : [
                                  farm.soilType,
                                  farm.irrigationType,
                                ].whereType<String>().join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: growing.isEmpty ? 'Belum aktif' : 'Aktif',
                    status: growing.isEmpty
                        ? AgriStatus.info
                        : AgriStatus.healthy,
                    small: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _FarmFact(
                      label: 'Tanaman aktif',
                      value: '${farm.activeCropCount}',
                    ),
                  ),
                  Expanded(
                    child: _FarmFact(
                      label: 'Luas',
                      value: farm.areaHectares == null
                          ? '—'
                          : '${_decimal(double.parse(farm.areaHectares!))} ha',
                    ),
                  ),
                  Expanded(
                    child: _FarmFact(
                      label: 'Varietas',
                      value: growing.isEmpty
                          ? '—'
                          : growing.first.seedVariety ??
                                _cropName(growing.first.cropType),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lihat rincian tanaman',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AgriColors.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AgriColors.canvas,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _cropName(crop.cropType),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusPill(
                  label: crop.status == 'growing'
                      ? 'Sedang tumbuh'
                      : crop.status,
                  status: crop.status == 'growing'
                      ? AgriStatus.healthy
                      : AgriStatus.info,
                  small: true,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              crop.seedVariety ?? 'Varietas belum tercatat',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Text(
                  'Umur ${crop.ageDays} hari',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Ditanam ${_dateLabel(crop.plantedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (crop.expectedHarvestAt != null)
                  Text(
                    'Panen ${_dateLabel(crop.expectedHarvestAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmFact extends StatelessWidget {
  const _FarmFact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const IconTile(
              icon: Icons.cloud_off_outlined,
              tint: AgriColors.amber,
              background: AgriColors.softAmber,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                'Data sementara belum tersedia. Coba perbarui dashboard.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFarmResult extends StatelessWidget {
  const _NoFarmResult({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            IconTile(
              icon: hasQuery ? Icons.search_off_rounded : Icons.eco_outlined,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              hasQuery ? 'Kebun tidak ditemukan' : 'Belum ada kebun tercatat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              hasQuery
                  ? 'Coba kata pencarian lain.'
                  : 'Daftarkan kebun melalui WhatsApp AgriSense.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCrops extends StatelessWidget {
  const _EmptyCrops();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Belum ada musim tanam pada kebun ini.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

String _decimal(double value) {
  final fixed = value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');
  return fixed.endsWith('.') ? fixed.substring(0, fixed.length - 1) : fixed;
}

String _cropName(String type) => switch (type.toLowerCase()) {
  'melon' => 'Melon',
  'rice' => 'Padi',
  'corn' => 'Jagung',
  'tomato' => 'Tomat',
  'chili' => 'Cabai',
  _ => type,
};

String _dateLabel(DateTime date) {
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
  final local = date.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
