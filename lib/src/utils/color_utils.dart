import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for color manipulation and generation.
class ColorUtils {
  /// Creates a color from HSL values.
  static Color hslToColor(double h, double s, double l) {
    h = h % 360;
    s = s.clamp(0.0, 1.0);
    l = l.clamp(0.0, 1.0);

    final double c = (1 - (2 * l - 1).abs()) * s;
    final double x = c * (1 - ((h / 60) % 2 - 1).abs());
    final double m = l - c / 2;

    double r, g, b;
    if (h < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (h < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (h < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (h < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (h < 300) {
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
  static Map<String, double> colorToHsl(Color color) {
    final double r = color.r;
    final double g = color.g;
    final double b = color.b;

    final double max = math.max(math.max(r, g), b);
    final double min = math.min(math.min(r, g), b);
    final double delta = max - min;

    double h, s, l;

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
  static Color interpolateColors(Color color1, Color color2, double factor) {
    factor = factor.clamp(0.0, 1.0);

    return Color.fromARGB(
      ((1 - factor) * color1.a + factor * color2.a).round(),
      ((1 - factor) * color1.r + factor * color2.r).round(),
      ((1 - factor) * color1.g + factor * color2.g).round(),
      ((1 - factor) * color1.b + factor * color2.b).round(),
    );
  }

  /// Creates a rainbow gradient based on frequency.
  static Color frequencyToColor(
      double frequency, double minFreq, double maxFreq) {
    final double normalizedFreq =
        ((frequency - minFreq) / (maxFreq - minFreq)).clamp(0.0, 1.0);

    // Create rainbow effect
    final double hue = normalizedFreq * 360;
    return hslToColor(hue, 0.8, 0.6);
  }

  /// Generates a complementary color.
  static Color getComplementaryColor(Color color) {
    final hsl = colorToHsl(color);
    final double complementaryHue = (hsl['h']! + 180) % 360;
    return hslToColor(complementaryHue, hsl['s']!, hsl['l']!);
  }

  /// Generates an analogous color scheme.
  static List<Color> getAnalogousColors(Color color, {int count = 3}) {
    final hsl = colorToHsl(color);
    final List<Color> colors = [];

    for (int i = 0; i < count; i++) {
      final double hue = (hsl['h']! + (i - count ~/ 2) * 30) % 360;
      colors.add(hslToColor(hue, hsl['s']!, hsl['l']!));
    }

    return colors;
  }

  /// Creates a monochromatic color scheme.
  static List<Color> getMonochromaticColors(Color color, {int count = 5}) {
    final hsl = colorToHsl(color);
    final List<Color> colors = [];

    for (int i = 0; i < count; i++) {
      final double lightness = 0.1 + (i * 0.8 / (count - 1));
      colors.add(hslToColor(hsl['h']!, hsl['s']!, lightness));
    }

    return colors;
  }

  /// Adjusts the brightness of a color.
  static Color adjustBrightness(Color color, double factor) {
    final hsl = colorToHsl(color);
    final double newLightness = (hsl['l']! * factor).clamp(0.0, 1.0);
    return hslToColor(hsl['h']!, hsl['s']!, newLightness);
  }

  /// Adjusts the saturation of a color.
  static Color adjustSaturation(Color color, double factor) {
    final hsl = colorToHsl(color);
    final double newSaturation = (hsl['s']! * factor).clamp(0.0, 1.0);
    return hslToColor(hsl['h']!, newSaturation, hsl['l']!);
  }

  /// Creates a color with adjusted alpha.
  static Color withAlpha(Color color, int alpha) {
    return Color.fromARGB(alpha, (color.r * 255).round(),
        (color.g * 255).round(), (color.b * 255).round());
  }

  /// Checks if a color is dark (useful for determining text color).
  static bool isDarkColor(Color color) {
    final double luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  /// Gets an appropriate text color for a background color.
  static Color getTextColor(Color backgroundColor) {
    return isDarkColor(backgroundColor) ? Colors.white : Colors.black;
  }

  /// Creates a gradient from a list of colors.
  static LinearGradient createLinearGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    if (colors.isEmpty) {
      colors = [Colors.blue, Colors.purple];
    }

    final List<double> stops = [];
    for (int i = 0; i < colors.length; i++) {
      stops.add(i / (colors.length - 1));
    }

    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// Creates a radial gradient from a list of colors.
  static RadialGradient createRadialGradient(
    List<Color> colors, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    if (colors.isEmpty) {
      colors = [Colors.blue, Colors.purple];
    }

    final List<double> stops = [];
    for (int i = 0; i < colors.length; i++) {
      stops.add(i / (colors.length - 1));
    }

    return RadialGradient(
      colors: colors,
      stops: stops,
      center: center,
      radius: radius,
    );
  }
}
