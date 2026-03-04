import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi loading widget.
/// CircularProgressIndicator yerine bu widget kullanılmalıdır.
/// Görünüm: . . .  [GIF]  . . .
class AppLoadingWidget extends StatefulWidget {
  final double size;
  final bool isSmall;

  const AppLoadingWidget({
    super.key,
    this.size = 80,
    this.isSmall = false,
  });

  const AppLoadingWidget.fullscreen({super.key})
      : size = 80,
        isSmall = false;

  const AppLoadingWidget.small({super.key})
      : size = 32,
        isSmall = true;

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(double delay, {required bool mirror}) {
    // Staggered: dot 1 → 0.0, dot 2 → 0.33, dot 3 → 0.66
    // If mirror, reverse order: dot 1 → 0.66, dot 2 → 0.33, dot 3 → 0.0
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + delay) % 1.0;
        // Pulse: scale between 0.4 and 1.0
        final scale = 0.4 + 0.6 * (1.0 - (2 * (t - 0.5)).abs());
        final opacity = 0.3 + 0.7 * scale;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale.clamp(0.4, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.isSmall ? 5 : 7,
        height: widget.isSmall ? 5 : 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDotGroup({required bool mirror}) {
    final spacing = widget.isSmall ? 4.0 : 6.0;
    // Left side: dots animate left→right (0.0, 0.33, 0.66)
    // Right side: mirror = true, so dots animate right→left (0.66, 0.33, 0.0)
    final delays = mirror ? [0.66, 0.33, 0.0] : [0.0, 0.33, 0.66];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(delays[0], mirror: mirror),
        SizedBox(width: spacing),
        _buildDot(delays[1], mirror: mirror),
        SizedBox(width: spacing),
        _buildDot(delays[2], mirror: mirror),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gifSize = widget.size;
    final horizontalPadding = widget.isSmall ? 8.0 : 14.0;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol noktalar . . .
          _buildDotGroup(mirror: false),
          SizedBox(width: horizontalPadding),
          // GIF
          SizedBox(
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
          SizedBox(width: horizontalPadding),
          // Sağ noktalar . . .
          _buildDotGroup(mirror: true),
        ],
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
