/// Defines the origin of the audio signal used for visualization.
enum AudioSourceType {
  /// Audio captured from the device's microphone input.
  microphone,

  /// Audio captured from an in-app audio player session.
  audioPlayer,

  /// Audio provided by a custom, developer-defined source.
  custom,

  /// Audio loaded and processed from a local file.
  file,

  /// Audio streamed and processed from a network URL.
  network,
}
