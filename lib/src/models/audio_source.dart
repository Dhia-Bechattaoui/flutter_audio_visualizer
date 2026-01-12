import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../enums/audio_source_type.dart';

/// Abstract representation of a source that provides raw audio data.
///
/// Subclasses must implement [start] and [stop] to manage the underlying
/// audio session and provide a [stream] of PCM byte data.
abstract class AudioSource {
  /// Creates an instance of [AudioSource].
  const AudioSource();

  /// The type of audio source (e.g., microphone, player).
  AudioSourceType get type;

  /// Whether the audio source is currently active and streaming.
  bool get isActive;

  /// A stream of raw PCM16 audio samples, typically 44.1kHz mono.
  Stream<List<int>>? get stream;

  /// Initializes and starts the audio capture session.
  Future<void> start();

  /// Stops the audio capture and releases session resources.
  Future<void> stop();

  /// Disposes of the audio source and cleans up any persistent resources.
  void dispose();
}

/// An [AudioSource] that captures audio from the device's microphone.
///
/// This implementation uses the `record` package and handles permission
/// requests and native session management (e.g., mic indicator).
class MicrophoneAudioSource extends AudioSource {
  /// Creates a microphone audio source with an optional [sampleRate].
  MicrophoneAudioSource({this.sampleRate = 44100});

  /// The sample rate to use for capture (default 44100Hz)
  final int sampleRate;

  Stream<List<int>>? _stream;
  bool _isActive = false;
  AudioRecorder? _recorder;

  @override
  AudioSourceType get type => AudioSourceType.microphone;

  @override
  bool get isActive => _isActive;

  @override
  Stream<List<int>>? get stream => _stream;

  @override
  Future<void> start() async {
    if (_isActive) {
      return;
    }

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    // Configure and start stream
    try {
      // Re-create recorder instance to ensure clean system session
      _recorder = AudioRecorder();

      final stream = await _recorder!.startStream(
        const RecordConfig(encoder: AudioEncoder.pcm16bits, numChannels: 1),
      );

      _stream = stream;
      _isActive = true;
    } catch (e) {
      throw Exception('Failed to start microphone: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (!_isActive) {
      return;
    }

    try {
      await _recorder?.stop();
      await _recorder?.dispose();
    } finally {
      _recorder = null;
      _isActive = false;
      _stream = null;
    }
  }

  @override
  void dispose() {
    unawaited(stop());
  }
}

/// Audio source from an audio player
class AudioPlayerSource extends AudioSource {
  /// Creates an audio player source
  const AudioPlayerSource();

  @override
  AudioSourceType get type => AudioSourceType.audioPlayer;

  @override
  bool get isActive => false; // Placeholder

  @override
  Stream<List<int>>? get stream => null; // Placeholder

  @override
  Future<void> start() async {
    // Implementation for starting audio player
  }

  @override
  Future<void> stop() async {
    // Implementation for stopping audio player
  }

  @override
  void dispose() {
    // Cleanup player resources
  }
}
