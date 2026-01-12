import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for color manipulation and generation.
class ColorUtils {
  // Prevent instantiation
  const ColorUtils._();

  /// Creates a color from HSL values.
  static Color hslToColor(final double h, final double s, final double l) {
    // Clone to local variables
    final hue = h % 360;
    final saturation = s.clamp(0.0, 1.0);
    final lightness = l.clamp(0.0, 1.0);

    final c = (1 - (2 * lightness - 1).abs()) * saturation;
    final x = c * (1 - ((hue / 60) % 2 - 1).abs());
    final m = lightness - c / 2;

    double r;
    double g;
    double b;
    if (hue < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (hue < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (hue < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (hue < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (hue < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    return Color.fromARGB(
      255,
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    );
  }

  /// Converts a color to HSL values.
  static Map<String, double> colorToHsl(final Color color) {
    // ... (unchanged)
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final double max = math.max(math.max(r, g), b);
    final double min = math.min(math.min(r, g), b);
    final delta = max - min;

    double h;
    double s;
    double l;

    // Calculate lightness
    l = (max + min) / 2;

    // Calculate saturation
    if (delta == 0) {
      h = 0;
      s = 0;
    } else {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      // Calculate hue
      if (max == r) {
        h = (g - b) / delta + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / delta + 2;
      } else {
        h = (r - g) / delta + 4;
      }
      h *= 60;
    }

    return {'h': h, 's': s, 'l': l};
  }

  /// Interpolates between two colors.
  static Color interpolateColors(
    final Color color1,
    final Color color2,
    final double factor,
  ) {
    final clampedFactor = factor.clamp(0.0, 1.0);

    return Color.fromARGB(
      ((1 - clampedFactor) * color1.a + clampedFactor * color2.a).round(),
      ((1 - clampedFactor) * color1.r + clampedFactor * color2.r).round(),
      ((1 - clampedFactor) * color1.g + clampedFactor * color2.g).round(),
      ((1 - clampedFactor) * color1.b + clampedFactor * color2.b).round(),
    );
  }

  // ... (unchanged)

  /// Creates a gradient from a list of colors.
  static LinearGradient createLinearGradient(
    final List<Color> colors, {
    final AlignmentGeometry begin = Alignment.centerLeft,
    final AlignmentGeometry end = Alignment.centerRight,
  }) {
    var gradientColors = colors;
    if (gradientColors.isEmpty) {
      gradientColors = [Colors.blue, Colors.purple];
    }

    final stops = <double>[];
    for (var i = 0; i < gradientColors.length; i++) {
      stops.add(i / (gradientColors.length - 1));
    }

    return LinearGradient(
      colors: gradientColors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// Creates a radial gradient from a list of colors.
  static RadialGradient createRadialGradient(
    final List<Color> colors, {
    final AlignmentGeometry center = Alignment.center,
    final double radius = 0.5,
  }) {
    var gradientColors = colors;
    if (gradientColors.isEmpty) {
      gradientColors = [Colors.blue, Colors.purple];
    }

    final stops = <double>[];
    for (var i = 0; i < gradientColors.length; i++) {
      stops.add(i / (gradientColors.length - 1));
    }

    return RadialGradient(
      colors: gradientColors,
      stops: stops,
      center: center,
      radius: radius,
    );
  }
}
