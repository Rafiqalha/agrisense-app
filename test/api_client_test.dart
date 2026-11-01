import 'dart:convert';

import 'package:agrisense_app/data/agrisense_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login mengirim kode ke API mobile dan membaca sesi terbatas', () async {
    late http.Request captured;
    final client = AgrisenseApiClient(
      apiOrigin: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'access_token': 'farmer-session-token',
            'expires_in': 900,
            'token_type': 'Bearer',
            'profile': {
              'user_id': 'user-a',
              'name': 'Petani Uji',
              'phone': '+6281111111111',
              'role': 'farmer',
              'status': 'active',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final session = await client.login(
      phone: '081111111111',
      code: 'ABCD2345WXYZ',
    );

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/mobile/session');
    expect(jsonDecode(captured.body), {
      'phone': '081111111111',
      'code': 'ABCD2345WXYZ',
    });
    expect(session.accessToken, 'farmer-session-token');
    expect(session.expiresIn, 900);
    expect(session.profile.name, 'Petani Uji');
    client.close();
  });

  test(
    'dashboard memakai bearer session dan memvalidasi struktur data',
    () async {
      late http.Request captured;
      final client = AgrisenseApiClient(
        apiOrigin: Uri.parse('https://example.test'),
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode(_dashboardJson()),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final dashboard = await client.dashboard('farmer-session-token');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/api/mobile/dashboard');
      expect(captured.headers['Authorization'], 'Bearer farmer-session-token');
      expect(dashboard.profile.name, 'Petani Uji');
      expect(dashboard.farms.data!.single.name, 'Kebun Uji');
      expect(dashboard.activities.data!.single.quantity, '10.000');
      client.close();
    },
  );

  test(
    'respons 401 menjadi sesi tidak sah tanpa membocorkan isi token',
    () async {
      final client = AgrisenseApiClient(
        apiOrigin: Uri.parse('https://example.test'),
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({'error': 'Sesi berakhir.'}),
            401,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      await expectLater(
        client.dashboard('secret-token'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.isUnauthorized, 'unauthorized', isTrue)
              .having((error) => error.message, 'message', 'Sesi berakhir.'),
        ),
      );
      client.close();
    },
  );
}

Map<String, dynamic> _dashboardJson() => {
  'profile': {
    'user_id': 'user-a',
    'name': 'Petani Uji',
    'phone': '+6281111111111',
    'status': 'active',
  },
  'generated_at': '2026-11-01T04:30:00Z',
  'data_environment': 'validation',
  'farms': {
    'status': 'available',
    'data': [
      {
        'id': 'farm-a',
        'name': 'Kebun Uji',
        'area_hectares': '0.1250',
        'soil_type': 'Tanah',
        'irrigation_type': 'Tetes',
        'active_crop_count': 1,
      },
    ],
  },
  'crops': {
    'status': 'available',
    'data': [
      {
        'id': 'crop-a',
        'farm_id': 'farm-a',
        'crop_type': 'melon',
        'seed_variety': 'Golden',
        'planted_at': '2026-09-16',
        'age_days': 28,
        'status': 'growing',
        'cultivation_system': 'greenhouse',
        'cultivation_unit_count': 2,
        'area_hectares': '0.1250',
        'expected_harvest_at': null,
      },
    ],
  },
  'harvests': {'status': 'available', 'data': <dynamic>[]},
  'activities': {
    'status': 'available',
    'data': [
      {
        'id': 'activity-a',
        'activity_type': 'watering',
        'description': 'Penyiraman tercatat',
        'quantity': '10.000',
        'unit': 'liter',
        'performed_at': '2026-10-14T01:00:00Z',
      },
    ],
  },
  'credit_score': {
    'status': 'available',
    'data': {
      'status': 'not_available',
      'score': null,
      'calculated_at': null,
      'valid_until': null,
    },
  },
};
