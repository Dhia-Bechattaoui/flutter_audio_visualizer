import 'package:flutter/material.dart';
import 'package:flutter_audio_visualizer/src/controllers/visualization_controller.dart';
import 'package:flutter_audio_visualizer/src/models/visualization_style.dart';

/// Widget for displaying spectrum visualization.
class SpectrumVisualizer extends StatelessWidget {
  /// Creates an instance of [SpectrumVisualizer].
  const SpectrumVisualizer({
    super.key,
    required this.data,
    required this.style,
  });

  /// The visualization data to display
  final VisualizationData data;

  /// The style for the visualization
  final AudioVisualizerStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpectrumPainter(
        bars: data.bars,
        style: style,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for drawing the spectrum visualization.
class SpectrumPainter extends CustomPainter {
  /// Creates an instance of [SpectrumPainter].
  SpectrumPainter({
    required this.bars,
    required this.style,
  });

  /// The bar data for the spectrum
  final List<double> bars;

  /// The style for the visualization
  final AudioVisualizerStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final paint = Paint()
      ..color = style.spectrumColor
      ..style = PaintingStyle.fill;

    final double barWidth = style.barWidth;
    final double barSpacing = style.barSpacing;
    final double totalBarWidth = barWidth + barSpacing;
    final int barCount = bars.length;

    // Calculate the total width needed for all bars
    final double totalWidth = barCount * totalBarWidth - barSpacing;

    // Center the visualization
    final double startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < barCount; i++) {
      final double barHeight = bars[i] * size.height;
      final double x = startX + i * totalBarWidth;
      final double y =
          size.height - barHeight; // Spectrum bars grow from bottom

      // Create rounded rectangle for the bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(style.borderRadius.topLeft.x),
      );

      // Apply gradient if specified
      if (style.gradient != null) {
        final gradientPaint = Paint()
          ..shader = style.gradient!.createShader(rect.outerRect);

        canvas.drawRRect(rect, gradientPaint);
      } else {
        canvas.drawRRect(rect, paint);
      }

      // Apply shadow if specified
      if (style.shadow != null) {
        final shadowRect = rect
            .shift(Offset(style.shadow!.offset.dx, style.shadow!.offset.dy));
        final shadowPaint = Paint()
          ..color = style.shadow!.color
              .withValues(alpha: style.shadow!.color.a * style.shadow!.color.a)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, style.shadow!.blurRadius);

        canvas.drawRRect(shadowRect, shadowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is SpectrumPainter) {
      return oldDelegate.bars != bars || oldDelegate.style != style;
    }
    return true;
  }
}
