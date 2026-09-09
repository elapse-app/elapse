// The repository token is the release fallback; VEX_API_TOKEN can override it
// without requiring a source change when the credential is rotated.
const String _vexApiToken = String.fromEnvironment(
  'VEX_API_TOKEN',
  defaultValue:
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiZDgzMWVkNGZlNmFlYmVlMTI2NDg5YmViYjFmMTAwOGU2NmU5YjRkYTc4ZTMzNDFhMzJiNDZlYTg1YzI0YjQ3MmYwM2VhMWMyYjk2OTJkNGYiLCJpYXQiOjE3ODY1MDQzMDMuMTI3MDk0LCJuYmYiOjE3ODY1MDQzMDMuMTI3MDk2OSwiZXhwIjoyNzMzMjc1NTAzLjExODMsInN1YiI6IjE2MTc0MSIsInNjb3BlcyI6W119.mqa5JafaSCmQ1-kywB5dMTENfQYfwO4AcNWrWp_p_cjwontl4zAMI5-tBCxG7CbK-6_Wgg8kUatD4ntBjp0ib-3b-32g6b5JwDEju1rRFe3sMP68Be9f-RilSQjtv0obHXeDT2guDx660r_T2KJoLquTMke_oBR4VbEc1JHYrjiaW5wIoyNqK3eQ6yKV8Q26GYjvIEViuKq3C7_gbR8NbJvr5PqmoWop2BoNY5R1s4qOWx_mg-ir-U9B_J5wXmKec1ZuWA60Mz9lQ0P2Y-k0kp1Fj6MSWqqkqVilt42r4vK0FDh7S95M-18aWbMPenDsYkfcDUfRGwDT_Tz6F1rZ_KBOn3sCjCcAxIUbqZNdA3LtJzw6DOYQGk8cFnYkkgDMEBqbPcsv0d2WVcinMVIxWP_d-idWbFnFSIC-6w2Zry0AnymQBdudxYUxrDmHh335RMFZYwr16Pp8s5AQxOz_8oCRiscD3U39KsiAiBZA8scqm6d1Wwn3OrTs_gN_TmGV8iHYbhRxFnuxMfrHGN_bdct_VdYWfwiF0MlgOBbcPvNb8dtm71D6Fq1mCi6YoQ-m_E2WjQ25IZigAX9_A0nA0TDWse-3HWNZl4IXeWV5Mh9rSixiGGRQAMPpNRCOVgZFgoZRAJOF0T0TTtrEYFRDvMn2JLrYK5n89jb8y402fCc',
);

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
