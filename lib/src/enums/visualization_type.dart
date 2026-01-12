/// Defines the visual representation used for the audio data.
enum VisualizationType {
  /// Renders a real-time amplitude waveform (time domain).
  waveform,

  /// Renders a frequency spectrum analyzer using FFT (frequency domain).
  spectrum,

  /// Renders both waveform and spectrum visualizations simultaneously.
  combined,
}
