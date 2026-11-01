import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/farmer_dashboard.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

class LoginSession {
  const LoginSession({
    required this.accessToken,
    required this.expiresIn,
    required this.profile,
  });

  final String accessToken;
  final int expiresIn;
  final FarmerProfile profile;
}

class AgrisenseApiClient {
  AgrisenseApiClient({http.Client? httpClient, Uri? apiOrigin})
    : _http = httpClient ?? http.Client(),
      _origin = apiOrigin ?? AppConfig.apiOrigin;

  final http.Client _http;
  final Uri _origin;
  static const _timeout = Duration(seconds: 15);
  static const _maximumBodyBytes = 1024 * 1024;

  Future<LoginSession> login({
    required String phone,
    required String code,
  }) async {
    final response = await _send(
      () => _http.post(
        _uri('/api/mobile/session'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'code': code}),
      ),
    );
    final json = _decode(response);
    final token = json['access_token'];
    final expiresIn = json['expires_in'];
    if (token is! String ||
        token.isEmpty ||
        token.length > 4096 ||
        RegExp(r'\s').hasMatch(token) ||
        expiresIn is! int ||
        expiresIn != 900) {
      throw const ApiException('Respons sesi dari server tidak valid.');
    }
    return LoginSession(
      accessToken: token,
      expiresIn: expiresIn,
      profile: FarmerProfile.fromJson(_jsonMap(json['profile'])),
    );
  }

  Future<FarmerDashboard> dashboard(String token) async {
    final response = await _send(
      () => _http.get(
        _uri('/api/mobile/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return FarmerDashboard.fromJson(_decode(response));
  }

  Uri _uri(String path) => _origin.replace(path: path);

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.bodyBytes.length > _maximumBodyBytes) {
        throw const ApiException('Respons server terlalu besar.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        var message = 'Layanan AgriSense belum dapat diakses.';
        try {
          final error = _jsonMap(jsonDecode(utf8.decode(response.bodyBytes)));
          if (error['error'] is String &&
              (error['error'] as String).isNotEmpty) {
            message = error['error'] as String;
          }
        } catch (_) {}
        throw ApiException(message, statusCode: response.statusCode);
      }
      return response;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Tidak dapat terhubung. Periksa internet lalu coba lagi.',
      );
    }
  }

  JsonMap _decode(http.Response response) {
    try {
      return _jsonMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (_) {
      throw const ApiException('Respons server tidak dapat dibaca.');
    }
  }

  void close() => _http.close();
}

JsonMap _jsonMap(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Bukan objek JSON.');
  }
  return value;
}
