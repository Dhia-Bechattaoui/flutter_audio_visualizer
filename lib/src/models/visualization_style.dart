import 'package:flutter/material.dart';

/// Configuration for the visual appearance of the audio visualization.
///
/// Use this class to customize colors, bar dimensions, animations, and other
/// stylistic properties of the visualizer.
@immutable
class AudioVisualizerStyle {
  /// Creates a style configuration with sensible defaults.
  const AudioVisualizerStyle({
    this.waveformColor = Colors.blue,
    this.spectrumColor = Colors.green,
    this.backgroundColor = Colors.transparent,
    this.barWidth = 3.0,
    this.barSpacing = 1.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.gradient,
    this.borderRadius = BorderRadius.zero,
    this.shadow,
  });

  /// The primary color used for waveform visualization.
  final Color waveformColor;

  /// The primary color used for spectrum (FFT) visualization.
  final Color spectrumColor;

  /// The background color of the visualization area.
  final Color backgroundColor;

  /// The width of each individual visualization bar.
  final double barWidth;

  /// The horizontal spacing between visualization bars.
  final double barSpacing;

  /// The duration of the smoothing animation between data updates.
  final Duration animationDuration;

  /// An optional gradient applied to the visualization bars.
  final Gradient? gradient;

  /// The border radius applied to the visualization container.
  final BorderRadius borderRadius;

  /// An optional shadow for adding depth to the visualization.
  final BoxShadow? shadow;

  /// Creates a copy of this [AudioVisualizerStyle] with the given fields
  /// replaced.
  AudioVisualizerStyle copyWith({
    final Color? waveformColor,
    final Color? spectrumColor,
    final Color? backgroundColor,
    final double? barWidth,
    final double? barSpacing,
    final Duration? animationDuration,
    final Gradient? gradient,
    final BorderRadius? borderRadius,
    final BoxShadow? shadow,
  }) => AudioVisualizerStyle(
    waveformColor: waveformColor ?? this.waveformColor,
    spectrumColor: spectrumColor ?? this.spectrumColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    barWidth: barWidth ?? this.barWidth,
    barSpacing: barSpacing ?? this.barSpacing,
    animationDuration: animationDuration ?? this.animationDuration,
    gradient: gradient ?? this.gradient,
    borderRadius: borderRadius ?? this.borderRadius,
    shadow: shadow ?? this.shadow,
  );

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AudioVisualizerStyle &&
        other.waveformColor == waveformColor &&
        other.spectrumColor == spectrumColor &&
        other.backgroundColor == backgroundColor &&
        other.barWidth == barWidth &&
        other.barSpacing == barSpacing &&
        other.animationDuration == animationDuration &&
        other.gradient == gradient &&
        other.borderRadius == borderRadius &&
        other.shadow == shadow;
  }

  @override
  int get hashCode => Object.hash(
    waveformColor,
    spectrumColor,
    backgroundColor,
    barWidth,
    barSpacing,
    animationDuration,
    gradient,
    borderRadius,
    shadow,
  );
}
