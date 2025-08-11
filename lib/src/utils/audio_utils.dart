import 'dart:math' as math;
import 'package:flutter_audio_visualizer/src/constants/audio_constants.dart';
import 'package:flutter_audio_visualizer/src/models/audio_data.dart';

/// Utility functions for audio processing and analysis.
class AudioUtils {
  /// Normalizes audio amplitude to a 0.0-1.0 range.
  static double normalizeAmplitude(double amplitude) {
    return (amplitude - AudioConstants.minAmplitudeThreshold) /
        (AudioConstants.maxAmplitude - AudioConstants.minAmplitudeThreshold);
  }

  /// Applies smoothing to audio data to reduce jitter.
  static double smoothValue(
      double currentValue, double previousValue, double factor) {
    return (currentValue * factor) + (previousValue * (1.0 - factor));
  }

  /// Converts frequency to a logarithmic scale for better visualization.
  static double frequencyToLogScale(double frequency) {
    if (frequency <= 0) return 0.0;
    return (math.log(frequency) - math.log(AudioConstants.minFrequency)) /
        (math.log(AudioConstants.maxFrequency) -
            math.log(AudioConstants.minFrequency));
  }

  /// Converts linear amplitude to decibels.
  static double amplitudeToDecibels(double amplitude) {
    if (amplitude <= 0) return -60.0;
    return 20.0 * math.log(amplitude) / math.ln10;
  }

  /// Converts decibels to linear amplitude.
  static double decibelsToAmplitude(double decibels) {
    return math.pow(10.0, decibels / 20.0).toDouble();
  }

  /// Calculates the RMS (Root Mean Square) of audio samples.
  static double calculateRMS(List<double> samples) {
    if (samples.isEmpty) return 0.0;

    double sum = 0.0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return math.sqrt(sum / samples.length);
  }

  /// Applies a low-pass filter to reduce high-frequency noise.
  static double lowPassFilter(
      double input, double previousOutput, double alpha) {
    return alpha * input + (1.0 - alpha) * previousOutput;
  }

  /// Detects if audio is above a certain threshold.
  static bool isAudioActive(AudioData audioData, double threshold) {
    return audioData.amplitude > threshold;
  }

  /// Calculates the average frequency from spectrum data.
  static double calculateAverageFrequency(List<double> spectrum) {
    if (spectrum.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < spectrum.length; i++) {
      final frequency = i * AudioConstants.defaultSampleRate / spectrum.length;
      final weight = spectrum[i];
      weightedSum += frequency * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }
}
