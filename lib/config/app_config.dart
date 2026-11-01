abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'AGRISENSE_API_BASE_URL',
    defaultValue: 'https://agrisense-web-iota.vercel.app',
  );

  static const whatsAppNumber = '6285739527222';

  static Uri get apiOrigin {
    final uri = Uri.parse(apiBaseUrl);
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw StateError('AGRISENSE_API_BASE_URL harus berupa origin HTTPS.');
    }
    return uri.replace(path: '');
  }
}
