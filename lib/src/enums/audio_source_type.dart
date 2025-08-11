/// Defines the source type for audio data.
enum AudioSourceType {
  /// Audio from microphone input
  microphone,

  /// Audio from an audio player
  audioPlayer,

  /// Audio from a custom source
  custom,

  /// Audio from file
  file,

  /// Audio from network stream
  network,
}
