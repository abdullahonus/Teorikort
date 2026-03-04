import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi loading widget.
/// CircularProgressIndicator yerine bu widget kullanılmalıdır.
class AppLoadingWidget extends StatelessWidget {
  /// Boyut - tam sayfa loading için kullanılır
  final double size;

  /// Küçük inline loading (butonlar, liste öğeleri vs.) için
  final bool isSmall;

  const AppLoadingWidget({
    super.key,
    this.size = 80,
    this.isSmall = false,
  });

  /// Tam sayfa merkezi loading
  const AppLoadingWidget.fullscreen({super.key})
      : size = 80,
        isSmall = false;

  /// Küçük inline loading (ör: buton içi)
  const AppLoadingWidget.small({super.key})
      : size = 32,
        isSmall = true;

  @override
  Widget build(BuildContext context) {
    final double gifSize = isSmall ? size : size;
    return Center(
      child: SizedBox(
        width: gifSize,
        height: gifSize,
        child: Image.asset(
          'assets/loading/loading.gif',
          width: gifSize,
          height: gifSize,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// Tam sayfa Scaffold ile loading ekranı
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoadingWidget.fullscreen(),
    );
  }
}
