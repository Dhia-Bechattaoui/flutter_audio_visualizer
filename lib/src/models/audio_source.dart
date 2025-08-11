import 'package:flutter_audio_visualizer/src/enums/audio_source_type.dart';

/// Represents a source of audio data for visualization.
abstract class AudioSource {
  /// Creates an instance of [AudioSource].
  const AudioSource();

  /// The type of audio source
  AudioSourceType get type;

  /// Whether the audio source is currently active
  bool get isActive;

  /// Start the audio source
  Future<void> start();

  /// Stop the audio source
  Future<void> stop();

  /// Dispose of the audio source
  void dispose();
}

/// Audio source from microphone input
class MicrophoneAudioSource extends AudioSource {
  /// Creates a microphone audio source
  const MicrophoneAudioSource();

  @override
  AudioSourceType get type => AudioSourceType.microphone;

  @override
  bool get isActive =>
      false; // Will be implemented with actual microphone logic

  @override
  Future<void> start() async {
    // Implementation for microphone access
  }

  @override
  Future<void> stop() async {
    // Implementation for stopping microphone
  }

  @override
  void dispose() {
    // Cleanup microphone resources
  }
}

/// Audio source from an audio player
class AudioPlayerSource extends AudioSource {
  /// Creates an audio player source
  const AudioPlayerSource();

  @override
  AudioSourceType get type => AudioSourceType.audioPlayer;

  @override
  bool get isActive => false; // Will be implemented with actual player logic

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
