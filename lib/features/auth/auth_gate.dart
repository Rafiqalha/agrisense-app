import 'package:flutter/material.dart';

import '../../theme/agrisense_theme.dart';
import '../../widgets/agrisense_widgets.dart';
import '../dashboard/dashboard_shell.dart';
import 'login_page.dart';
import 'session_controller.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.controller});

  final SessionController controller;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.controller.initialize);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        if (controller.phase == SessionPhase.initializing ||
            (controller.phase == SessionPhase.loading &&
                controller.dashboard == null)) {
          return const _LoadingPage();
        }
        if (controller.phase == SessionPhase.signedOut) {
          return LoginPage(
            errorMessage: controller.errorMessage,
            isLoading: false,
            onLogin: ({required phone, required code}) =>
                controller.signIn(phone: phone, code: code),
          );
        }
        if (controller.phase == SessionPhase.failure ||
            controller.dashboard == null) {
          return _FailurePage(
            message: controller.errorMessage ?? 'Dashboard belum dapat dibuka.',
            onRetry: controller.refresh,
            onSignOut: controller.signOut,
          );
        }
        return DashboardShell(
          dashboard: controller.dashboard!,
          isRefreshing: controller.isRefreshing,
          syncError: controller.errorMessage,
          onRefresh: controller.refresh,
          onLogout: controller.signOut,
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(),
              SizedBox(height: 28),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(height: 14),
              Text(
                'Menghubungkan data kebun…',
                style: TextStyle(color: AgriColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailurePage extends StatelessWidget {
  const _FailurePage({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final Future<void> Function() onRetry;
  final Future<void> Function({String? message}) onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageContainer(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconTile(
                  icon: Icons.cloud_off_outlined,
                  tint: AgriColors.amber,
                  background: AgriColors.softAmber,
                  size: 58,
                ),
                const SizedBox(height: 18),
                Text(
                  'Data belum dapat dimuat',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRetry,
                    child: const Text('Coba lagi'),
                  ),
                ),
                TextButton(
                  onPressed: onSignOut,
                  child: const Text('Masuk dengan kode baru'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
