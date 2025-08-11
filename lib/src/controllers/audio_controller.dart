import 'dart:async';
import 'package:flutter_audio_visualizer/src/models/audio_data.dart';
import 'package:flutter_audio_visualizer/src/models/audio_source.dart';

/// Controller for managing audio sources and data processing.
class AudioController {
  /// Creates an instance of [AudioController].
  AudioController({
    AudioSource? audioSource,
    Duration updateInterval = const Duration(milliseconds: 16), // ~60 FPS
  })  : _audioSource = audioSource,
        _updateInterval = updateInterval;

  AudioSource? _audioSource;
  Timer? _updateTimer;
  bool _isActive = false;
  final Duration _updateInterval;

  /// Stream controller for audio data
  final StreamController<AudioData> _audioDataController =
      StreamController<AudioData>.broadcast();

  /// Stream of audio data
  Stream<AudioData> get audioDataStream => _audioDataController.stream;

  /// Whether the audio controller is currently active
  bool get isActive => _isActive;

  /// The current audio source
  AudioSource? get audioSource => _audioSource;

  /// Sets the audio source for this controller
  void setAudioSource(AudioSource audioSource) {
    if (_isActive) {
      stop();
    }
    _audioSource = audioSource;
  }

  /// Starts the audio controller
  Future<void> start() async {
    if (_isActive || _audioSource == null) return;

    try {
      await _audioSource!.start();
      _isActive = true;

      // Start periodic updates
      _updateTimer = Timer.periodic(_updateInterval, (_) {
        _processAudioData();
      });
    } catch (e) {
      _isActive = false;
      rethrow;
    }
  }

  /// Stops the audio controller
  Future<void> stop() async {
    if (!_isActive) return;

    _updateTimer?.cancel();
    _updateTimer = null;

    if (_audioSource != null) {
      await _audioSource!.stop();
    }

    _isActive = false;
  }

  /// Processes audio data from the current source
  void _processAudioData() {
    if (_audioSource == null || !_isActive) return;

    try {
      // Generate mock audio data for now
      // In a real implementation, this would get data from the audio source
      final audioData = _generateMockAudioData();
      _audioDataController.add(audioData);
    } catch (e) {
      // Handle errors gracefully
      print('Error processing audio data: $e');
    }
  }

  /// Generates mock audio data for testing purposes
  AudioData _generateMockAudioData() {
    final now = DateTime.now();
    final amplitude = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
    final frequency = 440.0 + (amplitude * 2000.0); // 440Hz to 2440Hz

    return AudioData(
      amplitude: amplitude,
      frequency: frequency,
      timestamp: now,
      phase: (now.millisecondsSinceEpoch % 628) / 100.0, // 0 to 2π
    );
  }

  /// Disposes of the controller and cleans up resources
  void dispose() {
    stop();
    _audioDataController.close();
    _audioSource?.dispose();
  }
}
