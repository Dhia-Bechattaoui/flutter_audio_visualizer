import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../enums/visualization_type.dart';
import '../models/audio_data.dart';
import '../models/visualization_style.dart';

/// Controller for managing visualization state and rendering logic.
///
/// This class is responsible for converting [AudioData] into
/// [VisualizationData] suitable for rendering. It implements:
/// * **Temporal Smoothing**: Prevents jitter by interpolating between frames.
/// * **Frequency Blurring**: Smooths transitions between adjacent spectrum
///   bars.
/// * **Visual Scaling**: Enhances dynamic range for a more energetic look.
class VisualizationController {
  /// Creates an instance of [VisualizationController].
  VisualizationController({
    this.visualizationType = VisualizationType.waveform,
    this.style = const AudioVisualizerStyle(),
  });

  /// The current visualization type (waveform, spectrum, or combined).
  VisualizationType visualizationType;

  /// The current visual style configuration.
  AudioVisualizerStyle style;
  bool _isActive = false;

  /// Stream controller for visualization data
  final StreamController<VisualizationData> _visualizationDataController =
      StreamController<VisualizationData>.broadcast();

  /// A broadcast stream of processed visualization data.
  Stream<VisualizationData> get visualizationDataStream =>
      _visualizationDataController.stream;

  /// Whether the controller is active and processing data.
  bool get isActive => _isActive;

  List<double>? _prevWaveformBars;
  List<double>? _prevSpectrumBars;
  static const double _smoothingFactor = 0.4; // Lower = snappier
  static const double _decayFactor = 0.75; // Lower = faster fall

  /// Starts the visualization controller.
  void start() {
    if (_isActive) {
      return;
    }
    _isActive = true;
  }

  /// Stops the visualization controller.
  void stop() {
    if (!_isActive) {
      return;
    }
    _isActive = false;
  }

  /// Updates the visualization by processing new [AudioData].
  ///
  /// This generates new [VisualizationData] and emits it to the stream.
  void updateData(final AudioData audioData) {
    if (!_isActive) {
      return;
    }

    try {
      final visualizationData = _processAudioData(audioData);

      _visualizationDataController.add(visualizationData);
    } on Exception catch (_) {
      // Handle errors gracefully
    }
  }

  /// Generates visualization data based on incoming audio data
  VisualizationData _processAudioData(final AudioData audioData) {
    switch (visualizationType) {
      case VisualizationType.waveform:
        return _generateWaveformData(audioData);
      case VisualizationType.spectrum:
        return _generateSpectrumData(audioData);
      case VisualizationType.combined:
        return _generateCombinedData(audioData);
    }
  }

  /// Generates waveform visualization data
  VisualizationData _generateWaveformData(final AudioData audioData) {
    // For waveform, we ideally need raw samples. AudioData currently provides
    // spectrum and amplitude/frequency. However, we don't have the raw buffer in AudioData (yet).
    // As a temporary fix for "realness", we can simulate a waveform that reacts to amplitude/frequency
    // OR we should update AudioData to carry the raw buffer (better).
    // For now, let's make the bars react to the spectrum if available
    // (as a rough approximation of energy) or just amplitude.

    // Better approach: Use spectrum as the source for "waveform-like" look
    // if raw samples aren't there, or just map spectrum energy.
    // Ideally, AudioData should have `rawSamples` list.
    // Given the constraints and existing `AudioData` definition,
    // we'll map Spectrum to the bars but mirrored to look like a waveform.

    final spectrum = audioData.spectrum ?? [];
    List<double> bars;

    if (spectrum.isNotEmpty) {
      // Create a mirrored waveform look from spectrum
      // Take lower frequencies which have more energy usually
      const barCount = 64;
      bars = List.filled(barCount, 0);

      // Map spectrum to bars. Spectrum (FFT) is usually 0 to Nyquist.
      // We'll take first N bins.
      for (var i = 0; i < barCount; i++) {
        if (i < spectrum.length) {
          // Use square root for better visual dynamic range
          // and reduce sensitivity
          bars[i] = math.sqrt(spectrum[i]) * 3.0;
          if (bars[i] > 1.0) {
            bars[i] = 1.0;
          }
        }
      }

      bars = _postProcessBars(bars, VisualizationType.waveform);
    } else {
      // Fallback to amplitude with some jitter
      bars = _postProcessBars(
        List.filled(64, audioData.amplitude),
        VisualizationType.waveform,
      );
    }

    return VisualizationData(
      type: VisualizationType.waveform,
      bars: bars,
      timestamp: audioData.timestamp,
      style: style,
    );
  }

  /// Generates spectrum visualization data
  VisualizationData _generateSpectrumData(final AudioData audioData) {
    final spectrum = audioData.spectrum ?? [];
    List<double> bars;

    if (spectrum.isNotEmpty) {
      // Map spectrum directly
      // Resample or bin spectrum to fit our desired bar count (e.g. 32 or 64)
      // Simple approach: Take first 64 bins
      const barCount = 64;
      bars = List.filled(barCount, 0);

      for (var i = 0; i < barCount; i++) {
        if (i < spectrum.length) {
          // Use square root for better visual dynamic range
          // and reduce sensitivity
          bars[i] = math.sqrt(spectrum[i]) * 3.0;
          if (bars[i] > 1.0) {
            bars[i] = 1.0;
          }
        }
      }
      bars = _postProcessBars(bars, VisualizationType.spectrum);
    } else {
      bars = _postProcessBars(
        List.filled(64, 0.01),
        VisualizationType.spectrum,
      );
    }

    return VisualizationData(
      type: VisualizationType.spectrum,
      bars: bars,
      timestamp: audioData.timestamp,
      style: style,
    );
  }

  /// Generates combined visualization data
  VisualizationData _generateCombinedData(final AudioData audioData) {
    final waveformData = _generateWaveformData(audioData);
    final spectrumData = _generateSpectrumData(audioData);

    return VisualizationData(
      type: VisualizationType.combined,
      bars: waveformData.bars,
      spectrumBars: spectrumData.bars,
      timestamp: audioData.timestamp,
      style: style,
    );
  }

  /// Disposes of the controller and cleans up resources
  void dispose() {
    stop();
    unawaited(_visualizationDataController.close());
  }

  /// Applies temporal smoothing and frequency blurring to raw visualization
  /// bars.
  List<double> _postProcessBars(
    final List<double> bars,
    final VisualizationType type,
  ) {
    if (bars.isEmpty) {
      return bars;
    }

    final barCount = bars.length;
    final smoothedBars = List<double>.filled(barCount, 0);

    // Get previous state based on type
    final List<double> prevList;
    if (type == VisualizationType.waveform) {
      _prevWaveformBars ??= List<double>.filled(barCount, 0);
      prevList = _prevWaveformBars!;
    } else {
      _prevSpectrumBars ??= List<double>.filled(barCount, 0);
      prevList = _prevSpectrumBars!;
    }

    // 1. Temporal Smoothing (Interpolate between frames)
    for (var i = 0; i < barCount; i++) {
      var val = bars[i];
      final prev = prevList[i];

      if (val < prev) {
        val = prev * _decayFactor;
      } else {
        val = prev + (val - prev) * (1.0 - _smoothingFactor);
      }
      smoothedBars[i] = val;
    }

    // 2. Frequency Blurring (Smooth between adjacent bars)
    final blurredBars = List<double>.filled(barCount, 0);
    for (var i = 0; i < barCount; i++) {
      double neighborsSum = 0;
      var count = 0;

      for (var j = -1; j <= 1; j++) {
        final idx = i + j;
        if (idx >= 0 && idx < barCount) {
          neighborsSum += smoothedBars[idx];
          count++;
        }
      }
      blurredBars[i] = neighborsSum / count;
    }

    // Save state back
    if (type == VisualizationType.waveform) {
      _prevWaveformBars = List.from(blurredBars);
    } else {
      _prevSpectrumBars = List.from(blurredBars);
    }

    return blurredBars;
  }
}

/// Data structure for visualization rendering.
@immutable
class VisualizationData {
  /// Creates an instance of [VisualizationData].
  const VisualizationData({
    required this.type,
    required this.bars,
    required this.timestamp,
    required this.style,
    this.spectrumBars,
  });

  /// The type of visualization
  final VisualizationType type;

  /// The main visualization bars (waveform or combined)
  final List<double> bars;

  /// The spectrum bars (for combined visualization)
  final List<double>? spectrumBars;

  /// When this data was generated
  final DateTime timestamp;

  /// The style to use for rendering
  final AudioVisualizerStyle style;

  /// Creates a copy of this [VisualizationData] with the given fields replaced.
  VisualizationData copyWith({
    final VisualizationType? type,
    final List<double>? bars,
    final List<double>? spectrumBars,
    final DateTime? timestamp,
    final AudioVisualizerStyle? style,
  }) => VisualizationData(
    type: type ?? this.type,
    bars: bars ?? this.bars,
    spectrumBars: spectrumBars ?? this.spectrumBars,
    timestamp: timestamp ?? this.timestamp,
    style: style ?? this.style,
  );
}
