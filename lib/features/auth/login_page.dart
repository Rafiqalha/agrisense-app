import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../theme/agrisense_theme.dart';
import '../../widgets/agrisense_widgets.dart';

typedef LoginCallback = Future<void> Function({
  required String phone,
  required String code,
});

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
    required this.isLoading,
    this.errorMessage,
  });

  final LoginCallback onLogin;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.onLogin(phone: _phone.text, code: _code.text);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.https('wa.me', '/${AppConfig.whatsAppNumber}', {
      'text': 'LOGIN',
    });
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp belum dapat dibuka di perangkat ini.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting || widget.isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 38),
                    Text(
                      'Pantau kebun dari mana saja.',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Gunakan nomor WhatsApp yang terdaftar di AgriSense. Anda hanya perlu kode saat sesi berakhir.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AgriColors.muted),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AgriColors.softGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD6E6D9)),
                      ),
                      child: Column(
                        children: [
                          _LoginStep(
                            number: '1',
                            title: 'Minta kode di WhatsApp',
                            description: 'Kirim pesan LOGIN ke AgriSense.',
                          ),
                          const SizedBox(height: 14),
                          _LoginStep(
                            number: '2',
                            title: 'Salin kode balasan',
                            description: 'Kode terdiri dari 12 karakter.',
                          ),
                          const SizedBox(height: 14),
                          _LoginStep(
                            number: '3',
                            title: 'Tempel kode di bawah',
                            description: 'Kode hanya dapat digunakan sekali.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : _openWhatsApp,
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Buka WhatsApp dan kirim LOGIN'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nomor WhatsApp',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phone,
                      enabled: !busy,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [LengthLimitingTextInputFormatter(24)],
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: 'Contoh: 0857 1234 5678',
                      ),
                      validator: (value) {
                        final normalized = (value ?? '').replaceAll(
                          RegExp(r'[\s()+-]'),
                          '',
                        );
                        if (!RegExp(r'^(08|628|8)\d{7,13}$')
                            .hasMatch(normalized)) {
                          return 'Masukkan nomor WhatsApp yang benar.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Kode login',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _code,
                      enabled: !busy,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[A-Za-z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(64),
                      ],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.key_outlined),
                        hintText: 'ABCD2345WXYZ',
                      ),
                      validator: (value) {
                        final code = (value ?? '').trim();
                        if (!RegExp(r'^[A-HJ-NP-Za-hj-np-z2-9]{12}$')
                                .hasMatch(code) &&
                            !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(code)) {
                          return 'Tempel kode 12 karakter dari WhatsApp.';
                        }
                        return null;
                      },
                    ),
                    if (widget.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AgriColors.softRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AgriColors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                widget.errorMessage!,
                                style: const TextStyle(
                                  color: AgriColors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: busy ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Masuk ke dashboard'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Sesi disimpan aman di perangkat dan berlaku 15 menit.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginStep extends StatelessWidget {
  const _LoginStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AgriColors.green,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
