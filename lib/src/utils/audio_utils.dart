import 'dart:math' as math;
import '../constants/audio_constants.dart';
import '../models/audio_data.dart';

/// Utility class for various audio processing, normalization, and analysis
/// tasks.
class AudioUtils {
  // Prevent instantiation
  const AudioUtils._();

  /// Normalizes a raw audio [amplitude] to a standard 0.0 to 1.0 range.
  static double normalizeAmplitude(final double amplitude) =>
      (amplitude - AudioConstants.minAmplitudeThreshold) /
      (AudioConstants.maxAmplitude - AudioConstants.minAmplitudeThreshold);

  /// Applies exponential smoothing to [currentValue] based on a
  /// [previousValue].
  ///
  /// The [factor] determines the blend ratio (e.g., 0.8 favors new data).
  static double smoothValue(
    final double currentValue,
    final double previousValue,
    final double factor,
  ) => (currentValue * factor) + (previousValue * (1.0 - factor));

  /// Converts frequency to a logarithmic scale for better visualization.
  static double frequencyToLogScale(final double frequency) {
    if (frequency <= 0) {
      return 0;
    }
    return (math.log(frequency) - math.log(AudioConstants.minFrequency)) /
        (math.log(AudioConstants.maxFrequency) -
            math.log(AudioConstants.minFrequency));
  }

  /// Converts linear amplitude to decibels.
  static double amplitudeToDecibels(final double amplitude) {
    if (amplitude <= 0) {
      return -60;
    }
    return 20.0 * math.log(amplitude) / math.ln10;
  }

  /// Converts decibels to linear amplitude.
  static double decibelsToAmplitude(final double decibels) =>
      math.pow(10.0, decibels / 20.0).toDouble();

  /// Calculates the RMS (Root Mean Square) of audio samples.
  static double calculateRMS(final List<double> samples) {
    if (samples.isEmpty) {
      return 0;
    }

    var sum = 0.0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return math.sqrt(sum / samples.length);
  }

  /// Applies a low-pass filter to reduce high-frequency noise.
  static double lowPassFilter(
    final double input,
    final double previousOutput,
    final double alpha,
  ) => alpha * input + (1.0 - alpha) * previousOutput;

  /// Detects if audio is above a certain threshold.
  static bool isAudioActive(
    final AudioData audioData,
    final double threshold,
  ) => audioData.amplitude > threshold;

  /// Calculates the average frequency from spectrum data.
  static double calculateAverageFrequency(final List<double> spectrum) {
    if (spectrum.isEmpty) {
      return 0;
    }

    var weightedSum = 0.0;
    var totalWeight = 0.0;

    for (var i = 0; i < spectrum.length; i++) {
      final frequency = i * AudioConstants.defaultSampleRate / spectrum.length;
      final weight = spectrum[i];
      weightedSum += frequency * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }
}
