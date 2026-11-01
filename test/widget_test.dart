import 'package:agrisense_app/app.dart';
import 'package:agrisense_app/features/auth/login_page.dart';
import 'package:agrisense_app/features/dashboard/dashboard_shell.dart';
import 'package:agrisense_app/models/farmer_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard menampilkan data API dengan bahasa sederhana', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardApp());

    expect(find.text('Selamat datang,\nRafiq.'), findsOneWidget);
    expect(find.text('Data utama tersedia'), findsOneWidget);
    expect(find.text('Melon'), findsWidgets);
    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Kebun'), findsWidgets);
    expect(find.text('Aktivitas'), findsWidgets);
    expect(find.text('Akun'), findsWidgets);
  });

  testWidgets('navigasi bawah membuka data kebun dan akun', (tester) async {
    await tester.pumpWidget(_dashboardApp());

    await tester.tap(find.text('Kebun').last);
    await tester.pumpAndSettle();
    expect(find.text('Daftar kebun'), findsOneWidget);
    expect(find.text('Central Melon'), findsOneWidget);

    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Rafiq Alhariri'), findsOneWidget);
    expect(find.text('Koneksi data'), findsOneWidget);
  });

  testWidgets('pencarian kebun memberi keadaan kosong yang jelas', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardApp());
    await tester.tap(find.text('Kebun').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pump();
    expect(find.text('Kebun tidak ditemukan'), findsOneWidget);
    expect(find.text('Coba kata pencarian lain.'), findsOneWidget);
  });

  testWidgets('dashboard tidak overflow pada layar ponsel 390 piksel', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_dashboardApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
  });

  testWidgets('login meminta nomor dan kode WhatsApp yang valid', (
    tester,
  ) async {
    var submitted = false;
    await tester.pumpWidget(
      AgriSenseApp(
        home: LoginPage(
          isLoading: false,
          onLogin: ({required phone, required code}) async {
            submitted = true;
          },
        ),
      ),
    );

    await tester.ensureVisible(find.text('Masuk ke dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk ke dashboard'));
    await tester.pump();
    expect(find.text('Masukkan nomor WhatsApp yang benar.'), findsOneWidget);
    expect(find.text('Tempel kode 12 karakter dari WhatsApp.'), findsOneWidget);
    expect(submitted, isFalse);
  });
}

AgriSenseApp _dashboardApp() {
  return AgriSenseApp(
    home: DashboardShell(
      dashboard: _fixtureDashboard(),
      isRefreshing: false,
      onRefresh: () async {},
      onLogout: ({String? message}) async {},
    ),
  );
}

FarmerDashboard _fixtureDashboard() {
  return FarmerDashboard(
    profile: const FarmerProfile(
      userId: 'user-a',
      name: 'Rafiq Alhariri',
      phone: '+6285739527222',
      status: 'active',
    ),
    generatedAt: DateTime.utc(2026, 11, 1, 4, 30),
    dataEnvironment: 'validation',
    farms: const ReadSection(
      status: 'available',
      data: [
        Farm(
          id: 'farm-a',
          name: 'Central Melon',
          areaHectares: '0.1',
          soilType: 'Tanah',
          irrigationType: 'Tetes',
          activeCropCount: 1,
        ),
      ],
    ),
    crops: ReadSection(
      status: 'available',
      data: [
        Crop(
          id: 'crop-a',
          farmId: 'farm-a',
          cropType: 'melon',
          seedVariety: 'Golden Aroma',
          plantedAt: DateTime.utc(2026, 8, 10),
          ageDays: 83,
          status: 'growing',
          cultivationSystem: 'greenhouse',
          cultivationUnitCount: 2,
          areaHectares: '0.1',
          expectedHarvestAt: DateTime.utc(2026, 11, 8),
        ),
      ],
    ),
    harvests: ReadSection(
      status: 'available',
      data: [
        Harvest(
          id: 'harvest-a',
          farmId: 'farm-a',
          cropId: 'crop-a',
          yieldKg: '125.5',
          qualityGrade: 'A',
          pricePerKg: '18000',
          harvestedAt: DateTime.utc(2026, 10, 13),
        ),
      ],
    ),
    activities: ReadSection(
      status: 'available',
      data: [
        FarmActivity(
          id: 'activity-a',
          activityType: 'watering',
          description: 'Penyiraman tercatat',
          quantity: '10',
          unit: 'liter',
          performedAt: DateTime.utc(2026, 11, 1, 0, 15),
        ),
      ],
    ),
    creditScore: const ReadSection(
      status: 'available',
      data: CreditScore(
        status: 'not_available',
        score: null,
        calculatedAt: null,
        validUntil: null,
      ),
    ),
  );
}
