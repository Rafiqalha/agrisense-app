import 'package:flutter/material.dart';

import '../../../models/farmer_dashboard.dart';
import '../../../theme/agrisense_theme.dart';
import '../../../widgets/agrisense_widgets.dart';
import '../view_models.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.dashboard,
    required this.onLogout,
  });

  final FarmerDashboard dashboard;
  final Future<void> Function({String? message}) onLogout;

  @override
  Widget build(BuildContext context) {
    final profile = dashboard.profile;
    final initial = profile.name.trim().isEmpty
        ? 'A'
        : profile.name.trim()[0].toUpperCase();
    return CustomScrollView(
      key: const PageStorageKey('profile-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 7),
                Text(
                  'Informasi akun dan koneksi dashboard.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AgriColors.muted),
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AgriColors.softGreen,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AgriColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _maskPhone(profile.phone),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: profile.status == 'active'
                              ? 'Aktif'
                              : 'Menunggu',
                          status: profile.status == 'active'
                              ? AgriStatus.healthy
                              : AgriStatus.attention,
                          small: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeading(title: 'Koneksi data'),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      const _SettingsRow(
                        icon: Icons.chat_outlined,
                        title: 'WhatsApp AgriSense',
                        subtitle: 'Akun terautentikasi',
                        trailing: StatusPill(
                          label: 'Terhubung',
                          status: AgriStatus.healthy,
                          small: true,
                        ),
                      ),
                      const Divider(indent: 66),
                      _SettingsRow(
                        icon: Icons.sync_rounded,
                        title: 'Sinkronisasi terakhir',
                        subtitle:
                            '${_dateLabel(dashboard.generatedAt)} · ${_timeLabel(dashboard.generatedAt)}',
                        trailing: Icon(
                          dashboard.hasPartialFailure
                              ? Icons.info_rounded
                              : Icons.check_circle_rounded,
                          color: dashboard.hasPartialFailure
                              ? AgriColors.amber
                              : AgriColors.green,
                          size: 20,
                        ),
                      ),
                      const Divider(indent: 66),
                      _SettingsRow(
                        icon: Icons.cloud_outlined,
                        title: 'Lingkungan data',
                        subtitle: dashboard.dataEnvironment,
                        trailing: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeading(title: 'Ketersediaan data'),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      _DataStatusRow(
                        label: 'Kebun',
                        sectionStatus: dashboard.farms.status,
                      ),
                      const Divider(indent: 24),
                      _DataStatusRow(
                        label: 'Tanaman',
                        sectionStatus: dashboard.crops.status,
                      ),
                      const Divider(indent: 24),
                      _DataStatusRow(
                        label: 'Panen',
                        sectionStatus: dashboard.harvests.status,
                      ),
                      const Divider(indent: 24),
                      _DataStatusRow(
                        label: 'Aktivitas',
                        sectionStatus: dashboard.activities.status,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AgriColors.softBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        color: AgriColors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Token internal Railway tidak disimpan di aplikasi. Ponsel hanya menyimpan sesi akun Anda dalam penyimpanan aman perangkat.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AgriColors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar dari perangkat ini'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AgriColors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'AgriSense Mobile · versi 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari AgriSense?'),
        content: const Text(
          'Untuk masuk kembali, Anda perlu meminta kode LOGIN baru melalui WhatsApp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onLogout();
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: icon, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _DataStatusRow extends StatelessWidget {
  const _DataStatusRow({required this.label, required this.sectionStatus});

  final String label;
  final String sectionStatus;

  @override
  Widget build(BuildContext context) {
    final available = sectionStatus == 'available';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          StatusPill(
            label: available ? 'Tersedia' : 'Belum tersedia',
            status: available ? AgriStatus.healthy : AgriStatus.attention,
            small: true,
          ),
        ],
      ),
    );
  }
}

String _maskPhone(String phone) {
  if (phone.length < 8) return phone;
  return '${phone.substring(0, 5)} •••• ${phone.substring(phone.length - 3)}';
}

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
