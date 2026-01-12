/// Constants used for audio processing and visualization.
class AudioConstants {
  /// Default sample rate for audio processing (44.1 kHz)
  static const int defaultSampleRate = 44100;

  /// Default buffer size for audio processing
  static const int defaultBufferSize = 1024;

  /// Minimum frequency for audio visualization (20 Hz)
  static const double minFrequency = 20;

  /// Maximum frequency for audio visualization (20 kHz)
  static const double maxFrequency = 20000;

  /// Default FFT size for spectrum analysis
  static const int defaultFftSize = 512;

  /// Minimum amplitude threshold for visualization
  static const double minAmplitudeThreshold = 0.01;

  /// Maximum amplitude for normalization
  static const double maxAmplitude = 1;

  /// Default update rate for visualization (60 FPS)
  static const int defaultUpdateRate = 60;

  /// Default smoothing factor for visualization
  static const double defaultSmoothingFactor = 0.8;
}
