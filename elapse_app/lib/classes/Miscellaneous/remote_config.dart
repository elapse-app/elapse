import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance; // MODIFIED

  static FirebaseRemoteConfigService? _instance; // NEW
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._(); // NEW

  final FirebaseRemoteConfig _remoteConfig;

  bool getBool(String key) => _remoteConfig.getBool(key);

  Future<void> _setConfigSettings() async => _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          // Remote Config only controls optional feature availability. A slow
          // network should never delay the app becoming usable.
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(hours: 4),
        ),
      );

  Future<void> _setDefaults() async => _remoteConfig.setDefaults(
        const {
          FirebaseRemoteConfigKeys.vdaStatusKey: true,
        },
      );

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    if (updated) {
      debugPrint('The config has been updated.');
    } else {
      debugPrint('The config is not updated..');
    }
  }

  Future<void> initialize() async {
    try {
      await _setConfigSettings();
      await _setDefaults();
      await fetchAndActivate();
    } catch (error) {
      // The local defaults keep the existing UI functional while Firebase is
      // temporarily unavailable (for example, on an airplane or weak network).
      debugPrint('Remote Config unavailable: $error');
    }
  }
}

class FirebaseRemoteConfigKeys {
  static const String vdaStatusKey = 'isVDAWorking';
}
