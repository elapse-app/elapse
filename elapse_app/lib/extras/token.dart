const String _vexApiToken = String.fromEnvironment('VEX_API_TOKEN');

String getToken() {
  return buildAuthorizationHeader(_vexApiToken);
}

String buildAuthorizationHeader(String rawToken) {
  final token = rawToken.trim();
  if (token.isEmpty) {
    throw StateError(
      'VEX_API_TOKEN is missing. Pass it with '
      '--dart-define=VEX_API_TOKEN=<token>.',
    );
  }
  return token.startsWith('Bearer ') ? token : 'Bearer $token';
}
