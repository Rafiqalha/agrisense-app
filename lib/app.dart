import 'package:flutter/material.dart';

import 'data/agrisense_api_client.dart';
import 'data/session_store.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/session_controller.dart';
import 'theme/agrisense_theme.dart';

class AgriSenseApp extends StatelessWidget {
  const AgriSenseApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSense',
      debugShowCheckedModeBanner: false,
      theme: AgriSenseTheme.light,
      home: home ?? const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SessionController(AgrisenseApiClient(), SecureSessionStore());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthGate(controller: _controller);
}
