/// Represents audio data for visualization purposes.
class AudioData {
  /// Creates an instance of [AudioData].
  const AudioData({
    required this.amplitude,
    required this.frequency,
    required this.timestamp,
    this.phase,
    this.spectrum,
  });

  /// The amplitude of the audio signal (0.0 to 1.0)
  final double amplitude;

  /// The frequency of the audio signal in Hz
  final double frequency;

  /// The timestamp when this data was captured
  final DateTime timestamp;

  /// The phase of the audio signal in radians
  final double? phase;

  /// The frequency spectrum data (for FFT analysis)
  final List<double>? spectrum;

  /// Creates a copy of this [AudioData] with the given fields replaced.
  AudioData copyWith({
    double? amplitude,
    double? frequency,
    DateTime? timestamp,
    double? phase,
    List<double>? spectrum,
  }) {
    return AudioData(
      amplitude: amplitude ?? this.amplitude,
      frequency: frequency ?? this.frequency,
      timestamp: timestamp ?? this.timestamp,
      phase: phase ?? this.phase,
      spectrum: spectrum ?? this.spectrum,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioData &&
        other.amplitude == amplitude &&
        other.frequency == frequency &&
        other.timestamp == timestamp &&
        other.phase == phase &&
        other.spectrum == spectrum;
  }

  @override
  int get hashCode {
    return Object.hash(
      amplitude,
      frequency,
      timestamp,
      phase,
      spectrum,
    );
  }

  @override
  String toString() {
    return 'AudioData(amplitude: $amplitude, frequency: $frequency, '
        'timestamp: $timestamp, phase: $phase, spectrum: $spectrum)';
  }
}
