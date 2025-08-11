import 'package:flutter/material.dart';
import 'package:flutter_audio_visualizer/src/controllers/audio_controller.dart';
import 'package:flutter_audio_visualizer/src/controllers/visualization_controller.dart';
import 'package:flutter_audio_visualizer/src/enums/visualization_type.dart';
import 'package:flutter_audio_visualizer/src/models/audio_data.dart';
import 'package:flutter_audio_visualizer/src/models/visualization_style.dart';
import 'package:flutter_audio_visualizer/src/models/audio_source.dart';
import 'package:flutter_audio_visualizer/src/widgets/waveform_visualizer.dart';
import 'package:flutter_audio_visualizer/src/widgets/spectrum_visualizer.dart';

/// Main widget for audio visualization with customizable waveforms and spectrums.
class AudioVisualizer extends StatefulWidget {
  /// Creates an instance of [AudioVisualizer].
  const AudioVisualizer({
    super.key,
    this.audioSource,
    this.visualizationType = VisualizationType.waveform,
    this.style = const AudioVisualizerStyle(),
    this.onDataReceived,
    this.onError,
    this.height = 200.0,
    this.width,
  });

  /// The audio source to visualize
  final AudioSource? audioSource;

  /// The type of visualization to display
  final VisualizationType visualizationType;

  /// The visual style for the visualization
  final AudioVisualizerStyle style;

  /// Callback for when audio data is received
  final void Function(AudioData data)? onDataReceived;

  /// Callback for when errors occur
  final void Function(String error)? onError;

  /// The height of the visualization
  final double height;

  /// The width of the visualization (null for full width)
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

    _audioController = AudioController(
      audioSource: widget.audioSource,
    );

    _visualizationController = VisualizationController(
      visualizationType: widget.visualizationType,
      style: widget.style,
    );

    // Set up audio data stream
    _audioController.audioDataStream.listen(
      (data) {
        widget.onDataReceived?.call(data);
      },
      onError: (error) {
        widget.onError?.call(error.toString());
      },
    );

    // Start the controllers
    _audioController.start();
    _visualizationController.start();
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update visualization type if changed
    if (oldWidget.visualizationType != widget.visualizationType) {
      _visualizationController.setVisualizationType(widget.visualizationType);
    }

    // Update style if changed
    if (oldWidget.style != widget.style) {
      _visualizationController.setStyle(widget.style);
    }

    // Update audio source if changed
    if (oldWidget.audioSource != widget.audioSource) {
      if (widget.audioSource != null) {
        _audioController.setAudioSource(widget.audioSource!);
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
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: widget.style.borderRadius,
        boxShadow: widget.style.shadow != null ? [widget.style.shadow!] : null,
      ),
      child: StreamBuilder<VisualizationData>(
        stream: _visualizationController.visualizationDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildLoadingWidget();
          }

          final data = snapshot.data!;

          switch (data.type) {
            case VisualizationType.waveform:
              return WaveformVisualizer(
                data: data,
                style: widget.style,
              );

            case VisualizationType.spectrum:
              return SpectrumVisualizer(
                data: data,
                style: widget.style,
              );

            case VisualizationType.combined:
              return _buildCombinedVisualization(data);
          }
        },
      ),
    );
  }

  /// Builds the combined visualization (waveform + spectrum)
  Widget _buildCombinedVisualization(VisualizationData data) {
    return Column(
      children: [
        // Waveform visualization (top half)
        Expanded(
          child: WaveformVisualizer(
            data: data,
            style: widget.style,
          ),
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
                bars: data.spectrumBars!,
                type: VisualizationType.spectrum,
              ),
              style: widget.style,
            ),
          ),
      ],
    );
  }

  /// Builds the error widget
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Visualization Error',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(widget.style.waveformColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Initializing...',
            style: TextStyle(
              color: widget.style.waveformColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
