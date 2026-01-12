import 'dart:async';
import 'package:flutter/material.dart';

import '../controllers/audio_controller.dart';
import '../controllers/visualization_controller.dart';
import '../enums/visualization_type.dart';
import '../models/audio_data.dart';
import '../models/audio_source.dart';
import '../models/visualization_style.dart';
import 'spectrum_visualizer.dart';
import 'waveform_visualizer.dart';

/// A high-level widget for real-time audio visualization.
///
/// This widget coordinates an [AudioController] and [VisualizationController]
/// to provide a declarative way to render waveforms and spectrums. It handles
/// the underlying stream management and provides a set of customizable styles.
///
/// Example:
/// ```dart
/// AudioVisualizer(
///   audioSource: MicrophoneAudioSource(),
///   visualizationType: VisualizationType.spectrum,
///   style: AudioVisualizerStyle(
///     waveformColor: Colors.blue,
///     barWidth: 4.0,
///   ),
/// )
/// ```
class AudioVisualizer extends StatefulWidget {
  /// Creates an instance of [AudioVisualizer].
  const AudioVisualizer({
    super.key,
    this.audioSource,
    this.visualizationType = VisualizationType.waveform,
    this.style = const AudioVisualizerStyle(),
    this.isActive = true,
    this.onDataReceived,
    this.onError,
    this.height = 200.0,
    this.width,
  });

  /// The audio source to visualize. If null, no data will be processed.
  final AudioSource? audioSource;

  /// The type of visualization to display (waveform, spectrum, or combined).
  final VisualizationType visualizationType;

  /// The visual style configuration for the visualization.
  final AudioVisualizerStyle style;

  /// Whether the visualizer is currently active and processing audio data.
  final bool isActive;

  /// Callback for when a new frame of [AudioData] is processed.
  final void Function(AudioData data)? onDataReceived;

  /// Callback invoked when an error occurs during audio capture or processing.
  final void Function(String error)? onError;

  /// The height of the visualization area.
  final double height;

  /// The width of the visualization area. If null, it takes up all available
  /// space.
  final double? width;

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  late AudioController _audioController;
  late VisualizationController _visualizationController;

  @override
  void initState() {
    super.initState();

    _audioController = AudioController(audioSource: widget.audioSource);

    _visualizationController = VisualizationController(
      visualizationType: widget.visualizationType,
      style: widget.style,
    );

    // Set up audio data stream
    _audioController.audioDataStream.listen(
      (final data) {
        widget.onDataReceived?.call(data);
        _visualizationController.updateData(data);
      },
      onError: (final Object error) {
        widget.onError?.call(error.toString());
      },
    );

    // Start the controllers
    if (widget.isActive) {
      unawaited(_audioController.start());
      _visualizationController.start();
    }
  }

  @override
  void didUpdateWidget(final AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update visualization type if changed
    if (oldWidget.visualizationType != widget.visualizationType) {
      _visualizationController.visualizationType = widget.visualizationType;
    }

    // Update style if changed
    if (oldWidget.style != widget.style) {
      _visualizationController.style = widget.style;
    }

    // Update audio source if changed
    if (oldWidget.audioSource != widget.audioSource) {
      if (widget.audioSource != null) {
        _audioController.setAudioSource(widget.audioSource!);
        if (widget.isActive) {
          unawaited(_audioController.start());
        }
      }
    }

    // Update active state
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        unawaited(_audioController.start());
        _visualizationController.start();
      } else {
        unawaited(_audioController.stop());
        _visualizationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _audioController.dispose();
    _visualizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Container(
    width: widget.width,
    height: widget.height,
    decoration: BoxDecoration(
      color: widget.style.backgroundColor,
      borderRadius: widget.style.borderRadius,
      boxShadow: widget.style.shadow != null ? [widget.style.shadow!] : null,
    ),
    child: StreamBuilder<VisualizationData>(
      stream: _visualizationController.visualizationDataStream,
      builder: (final context, final snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildLoadingWidget();
        }

        final data = snapshot.data!;

        switch (data.type) {
          case VisualizationType.waveform:
            return WaveformVisualizer(data: data, style: widget.style);

          case VisualizationType.spectrum:
            return SpectrumVisualizer(data: data, style: widget.style);

          case VisualizationType.combined:
            return _buildCombinedVisualization(data);
        }
      },
    ),
  );

  /// Builds the combined visualization (waveform + spectrum)
  Widget _buildCombinedVisualization(final VisualizationData data) => Column(
    children: [
      // Waveform visualization (top half)
      Expanded(
        child: WaveformVisualizer(data: data, style: widget.style),
      ),

      // Divider
      Container(
        height: 1,
        color: widget.style.waveformColor.withValues(alpha: 0.3),
      ),

      // Spectrum visualization (bottom half)
      if (data.spectrumBars != null)
        Expanded(
          child: SpectrumVisualizer(
            data: data.copyWith(
              bars: data.spectrumBars,
              type: VisualizationType.spectrum,
            ),
            style: widget.style,
          ),
        ),
    ],
  );

  /// Builds the error widget
  Widget _buildErrorWidget(final String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        const Text(
          'Visualization Error',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          error,
          style: TextStyle(color: Colors.red[700], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  /// Builds the loading widget
  Widget _buildLoadingWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.style.waveformColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Initializing...',
          style: TextStyle(color: widget.style.waveformColor, fontSize: 14),
        ),
      ],
    ),
  );
}
