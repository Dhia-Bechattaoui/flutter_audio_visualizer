import 'package:flutter/material.dart';

/// Defines the visual style for audio visualization.
class AudioVisualizerStyle {
  /// Creates an instance of [AudioVisualizerStyle].
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

  /// Color for waveform visualization
  final Color waveformColor;

  /// Color for spectrum visualization
  final Color spectrumColor;

  /// Background color of the visualization
  final Color backgroundColor;

  /// Width of each visualization bar
  final double barWidth;

  /// Spacing between visualization bars
  final double barSpacing;

  /// Duration of animation transitions
  final Duration animationDuration;

  /// Optional gradient for enhanced visual appeal
  final Gradient? gradient;

  /// Border radius for the visualization container
  final BorderRadius borderRadius;

  /// Optional shadow for depth
  final BoxShadow? shadow;

  /// Creates a copy of this [AudioVisualizerStyle] with the given fields replaced.
  AudioVisualizerStyle copyWith({
    Color? waveformColor,
    Color? spectrumColor,
    Color? backgroundColor,
    double? barWidth,
    double? barSpacing,
    Duration? animationDuration,
    Gradient? gradient,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
  }) {
    return AudioVisualizerStyle(
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
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
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
  int get hashCode {
    return Object.hash(
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
}
