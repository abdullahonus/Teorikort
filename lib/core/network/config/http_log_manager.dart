import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'app_environment.dart';

@immutable
class HttpLogManager {
  HttpLogManager.check() {
    if (kDebugMode) {
      _productEnvironment = Environment.dev;
    } else {
      // Release build: preprod veya prod seçin
      _productEnvironment = Environment.prod;
    }
    _showLogger();
  }

  late final Environment _productEnvironment;

  void _showLogger() {
    switch (_productEnvironment) {
      case Environment.dev:
        ChuckerFlutter.isDebugMode = true;
        ChuckerFlutter.showOnRelease = true;
        ChuckerFlutter.showNotification = true;
        break;
      case Environment.preprod:
        ChuckerFlutter.isDebugMode = false;
        ChuckerFlutter.showOnRelease = true;
        ChuckerFlutter.showNotification = true;
        break;
      case Environment.prod:
        ChuckerFlutter.isDebugMode = false;
        ChuckerFlutter.showOnRelease = true;
        ChuckerFlutter.showNotification = false;
        break;
    }
  }

  static void show() {
    if (ChuckerFlutter.showOnRelease || ChuckerFlutter.isDebugMode) {
      ChuckerFlutter.showChuckerScreen();
    }
  }
}
