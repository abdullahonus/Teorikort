import 'package:flutter/material.dart';
import 'package:taxi/screens/onboarding/splash_screen.dart';

class ScreenRouteList {
  static Map<String, Widget Function(BuildContext)> screenRoutes = {
    '/splash': (context) => const SplashScreen(),

  };
}
