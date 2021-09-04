import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class RemoteConfigService {
  final StreamController<dynamic> _fetchingError =
      StreamController<dynamic>.broadcast();

  Stream<dynamic> get fetchingErrorStream => _fetchingError.stream;
  StreamController<dynamic> get fetchingErrorController => _fetchingError;

  Future<RemoteConfig> setRemoteConfig() async {
    await Firebase.initializeApp();
    var _remoteConfig = RemoteConfig.instance;
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 200),
        minimumFetchInterval: const Duration(minutes: 30)));

    _remoteConfig.setDefaults(<String, dynamic>{
      'showModal': false,
      'mainScreen': {
        'title': 'Demo',
        'showAdd': false,
        'iconSize': 10,
      }
    });

    RemoteConfigValue(null, ValueSource.valueStatic);
    return _remoteConfig;
  }

  Future<void> onForceFetched(RemoteConfig remoteConfig) async {
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero));
      await remoteConfig.fetchAndActivate();
    } on PlatformException catch (exception) {
      fetchingErrorController.add(exception.message);
    } catch (exception) {
      fetchingErrorController.add(exception.toString());
    }
  }
}
