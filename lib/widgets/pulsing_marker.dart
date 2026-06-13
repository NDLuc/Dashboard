import 'package:flutter/material.dart';

class PulsingMarker extends StatelessWidget {
  final Animation<double> pulse;
  final Color color;
  final double size;
  const PulsingMarker({
    super.key,
    required this.pulse,
    required this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final t = pulse.value;
        final ringOpacity = (1 - t).clamp(0.0, 1.0);
        final ringScale = 1 + 0.8 * t;
        final outer = size + 10;
        return SizedBox(
          width: outer,
          height: outer,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: size + 2,
                  height: size + 2,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14 * ringOpacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.24), blurRadius: 18)],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.33,
                    height: size * 0.33,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
