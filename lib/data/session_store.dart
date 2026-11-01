import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/farmer_dashboard.dart';

class StoredSession {
  const StoredSession({
    required this.token,
    required this.expiresAt,
    required this.profile,
  });

  final String token;
  final DateTime expiresAt;
  final FarmerProfile profile;
  bool get isExpired => DateTime.now().toUtc().isAfter(
    expiresAt.toUtc().subtract(const Duration(seconds: 15)),
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'profile': profile.toJson(),
  };

  factory StoredSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final expiresAt = DateTime.tryParse(json['expires_at']?.toString() ?? '');
    final profile = json['profile'];
    if (token is! String ||
        token.isEmpty ||
        token.length > 4096 ||
        RegExp(r'\s').hasMatch(token) ||
        expiresAt == null ||
        profile is! Map<String, dynamic>) {
      throw const FormatException('Sesi lokal tidak valid.');
    }
    return StoredSession(
      token: token,
      expiresAt: expiresAt,
      profile: FarmerProfile.fromJson(profile),
    );
  }
}

abstract interface class SessionStore {
  Future<StoredSession?> read();
  Future<void> write(StoredSession session);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'agrisense_mobile_session_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<StoredSession?> read() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic>) throw const FormatException();
      return StoredSession.fromJson(json);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(StoredSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
