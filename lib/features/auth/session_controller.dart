import 'package:flutter/foundation.dart';

import '../../data/agrisense_api_client.dart';
import '../../data/session_store.dart';
import '../../models/farmer_dashboard.dart';

enum SessionPhase { initializing, signedOut, loading, signedIn, failure }

class SessionController extends ChangeNotifier {
  SessionController(this._api, this._store);

  final AgrisenseApiClient _api;
  final SessionStore _store;
  SessionPhase phase = SessionPhase.initializing;
  StoredSession? session;
  FarmerDashboard? dashboard;
  String? errorMessage;
  bool isRefreshing = false;

  Future<void> initialize() async {
    phase = SessionPhase.initializing;
    notifyListeners();
    try {
      final saved = await _store.read();
      if (saved == null || saved.isExpired) {
        await _store.clear();
        phase = SessionPhase.signedOut;
        notifyListeners();
        return;
      }
      session = saved;
      await _loadDashboard(initial: true);
    } catch (_) {
      errorMessage = 'Penyimpanan sesi tidak dapat dibuka.';
      phase = SessionPhase.failure;
      notifyListeners();
    }
  }

  Future<void> signIn({required String phone, required String code}) async {
    phase = SessionPhase.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.login(phone: phone, code: code);
      final saved = StoredSession(
        token: result.accessToken,
        expiresAt: DateTime.now().toUtc().add(
          Duration(seconds: result.expiresIn),
        ),
        profile: result.profile,
      );
      await _store.write(saved);
      session = saved;
      await _loadDashboard(initial: true);
    } on ApiException catch (error) {
      errorMessage = error.message;
      phase = SessionPhase.signedOut;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Sesi tidak dapat disimpan dengan aman.';
      phase = SessionPhase.signedOut;
      notifyListeners();
    }
  }

  Future<void> refresh() => _loadDashboard(initial: false);

  Future<void> _loadDashboard({required bool initial}) async {
    final active = session;
    if (active == null || active.isExpired) {
      await signOut(
        message: 'Sesi berakhir. Minta kode LOGIN baru di WhatsApp.',
      );
      return;
    }
    if (initial) {
      phase = SessionPhase.loading;
    } else {
      isRefreshing = true;
    }
    errorMessage = null;
    notifyListeners();
    try {
      dashboard = await _api.dashboard(active.token);
      phase = SessionPhase.signedIn;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await signOut(message: error.message);
        return;
      }
      errorMessage = error.message;
      phase = dashboard == null ? SessionPhase.failure : SessionPhase.signedIn;
    } catch (_) {
      errorMessage = 'Data dashboard tidak dapat dibaca.';
      phase = dashboard == null ? SessionPhase.failure : SessionPhase.signedIn;
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> signOut({String? message}) async {
    await _store.clear();
    session = null;
    dashboard = null;
    errorMessage = message;
    isRefreshing = false;
    phase = SessionPhase.signedOut;
    notifyListeners();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
