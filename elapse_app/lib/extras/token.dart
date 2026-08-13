const String _vexApiToken = String.fromEnvironment('VEX_API_TOKEN');

String getToken() {
  final token = _vexApiToken.trim();
  if (token.isEmpty) {
    throw StateError(
      'VEX_API_TOKEN is not configured. Start Flutter with '
      '--dart-define=VEX_API_TOKEN=<token>.',
    );
  }

  return token.startsWith('Bearer ') ? token : 'Bearer $token';
}
