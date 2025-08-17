import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_audio_visualizer/src/enums/visualization_type.dart';
import 'package:flutter_audio_visualizer/src/models/visualization_style.dart';

/// Controller for managing visualization state and rendering.
class VisualizationController {
  /// Creates an instance of [VisualizationController].
  VisualizationController({
    VisualizationType visualizationType = VisualizationType.waveform,
    AudioVisualizerStyle style = const AudioVisualizerStyle(),
    Duration updateInterval = const Duration(milliseconds: 16), // ~60 FPS
  })  : _visualizationType = visualizationType,
        _style = style,
        _updateInterval = updateInterval;

  VisualizationType _visualizationType;
  AudioVisualizerStyle _style;
  final Duration _updateInterval;

  Timer? _updateTimer;
  bool _isActive = false;

  /// Stream controller for visualization data
  final StreamController<VisualizationData> _visualizationDataController =
      StreamController<VisualizationData>.broadcast();

  /// Stream of visualization data
  Stream<VisualizationData> get visualizationDataStream =>
      _visualizationDataController.stream;

  /// Current visualization type
  VisualizationType get visualizationType => _visualizationType;

  /// Current visualization style
  AudioVisualizerStyle get style => _style;

  /// Whether the visualization controller is active
  bool get isActive => _isActive;

  /// Sets the visualization type
  void setVisualizationType(VisualizationType type) {
    _visualizationType = type;
    _updateVisualization();
  }

  /// Sets the visualization style
  void setStyle(AudioVisualizerStyle style) {
    _style = style;
    _updateVisualization();
  }

  /// Starts the visualization controller
  void start() {
    if (_isActive) return;

    _isActive = true;
    _updateTimer = Timer.periodic(_updateInterval, (_) {
      _updateVisualization();
    });
  }

  /// Stops the visualization controller
  void stop() {
    if (!_isActive) return;

    _updateTimer?.cancel();
    _updateTimer = null;
    _isActive = false;
  }

  /// Updates the visualization with new data
  void _updateVisualization() {
    if (!_isActive) return;

    try {
      final visualizationData = _generateVisualizationData();
      _visualizationDataController.add(visualizationData);
    } catch (e) {
      // Handle errors gracefully
      // Error logged internally for debugging
    }
  }

  /// Generates visualization data based on current settings
  VisualizationData _generateVisualizationData() {
    final now = DateTime.now();

    switch (_visualizationType) {
      case VisualizationType.waveform:
        return _generateWaveformData(now);
      case VisualizationType.spectrum:
        return _generateSpectrumData(now);
      case VisualizationType.combined:
        return _generateCombinedData(now);
    }
  }

  /// Generates waveform visualization data
  VisualizationData _generateWaveformData(DateTime timestamp) {
    const barCount = 64;
    final bars = List<double>.filled(barCount, 0.0);

    // Generate mock waveform data
    for (int i = 0; i < barCount; i++) {
      final time = timestamp.millisecondsSinceEpoch / 1000.0;
      final frequency = 1.0 + (i / barCount);
      bars[i] = (0.5 + 0.5 * math.sin(time * frequency)).clamp(0.0, 1.0);
    }

    return VisualizationData(
      type: VisualizationType.waveform,
      bars: bars,
      timestamp: timestamp,
      style: _style,
    );
  }

  /// Generates spectrum visualization data
  VisualizationData _generateSpectrumData(DateTime timestamp) {
    const barCount = 64;
    final bars = List<double>.filled(barCount, 0.0);

    // Generate mock spectrum data
    for (int i = 0; i < barCount; i++) {
      final time = timestamp.millisecondsSinceEpoch / 1000.0;
      final frequency = i / barCount;
      bars[i] = (0.3 + 0.7 * math.sin(time * frequency * 2)).clamp(0.0, 1.0);
    }

    return VisualizationData(
      type: VisualizationType.spectrum,
      bars: bars,
      timestamp: timestamp,
      style: _style,
    );
  }

  /// Generates combined visualization data
  VisualizationData _generateCombinedData(DateTime timestamp) {
    final waveformData = _generateWaveformData(timestamp);
    final spectrumData = _generateSpectrumData(timestamp);

    return VisualizationData(
      type: VisualizationType.combined,
      bars: waveformData.bars,
      spectrumBars: spectrumData.bars,
      timestamp: timestamp,
      style: _style,
    );
  }

  /// Disposes of the controller and cleans up resources
  void dispose() {
    stop();
    _visualizationDataController.close();
  }
}

/// Data structure for visualization rendering.
class VisualizationData {
  /// Creates an instance of [VisualizationData].
  const VisualizationData({
    required this.type,
    required this.bars,
    this.spectrumBars,
    required this.timestamp,
    required this.style,
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
    VisualizationType? type,
    List<double>? bars,
    List<double>? spectrumBars,
    DateTime? timestamp,
    AudioVisualizerStyle? style,
  }) {
    return VisualizationData(
      type: type ?? this.type,
      bars: bars ?? this.bars,
      spectrumBars: spectrumBars ?? this.spectrumBars,
      timestamp: timestamp ?? this.timestamp,
      style: style ?? this.style,
    );
  }
}
