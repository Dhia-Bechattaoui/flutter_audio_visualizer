import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Basic enum tests', () {
    // Test visualization types
    expect(VisualizationType.values.length, 3);
    expect(VisualizationType.waveform, isA<VisualizationType>());
    expect(VisualizationType.spectrum, isA<VisualizationType>());
    expect(VisualizationType.combined, isA<VisualizationType>());

    // Test audio source types
    expect(AudioSourceType.values.length, 5);
    expect(AudioSourceType.microphone, isA<AudioSourceType>());
    expect(AudioSourceType.audioPlayer, isA<AudioSourceType>());
  });

  test('AudioData creation', () {
    final now = DateTime.now();
    final audioData = AudioData(amplitude: 0.5, frequency: 440, timestamp: now);

    expect(audioData.amplitude, 0.5);
    expect(audioData.frequency, 440.0);
    expect(audioData.timestamp, now);
  });

  test('AudioData copyWith', () {
    final original = AudioData(
      amplitude: 0.5,
      frequency: 440,
      timestamp: DateTime.now(),
    );

    final modified = original.copyWith(amplitude: 0.8);
    expect(modified.amplitude, 0.8);
    expect(modified.frequency, original.frequency);
  });

  test('AudioVisualizerStyle creation', () {
    const style = AudioVisualizerStyle();

    expect(style.barWidth, 3.0);
    expect(style.barSpacing, 1.0);
  });

  test('AudioVisualizerStyle copyWith', () {
    const original = AudioVisualizerStyle();
    final modified = original.copyWith(barWidth: 5);

    expect(modified.barWidth, 5.0);
    expect(modified.waveformColor, original.waveformColor);
  });

  test('AudioSource properties', () {
    final microphoneSource = MicrophoneAudioSource();
    const playerSource = AudioPlayerSource();

    expect(microphoneSource.type, AudioSourceType.microphone);
    expect(playerSource.type, AudioSourceType.audioPlayer);
  });

  test('Constants values', () {
    expect(AudioConstants.defaultSampleRate, 44100);
    expect(AudioConstants.defaultBufferSize, 1024);
    expect(VisualizationConstants.defaultBarWidth, 3.0);
    expect(VisualizationConstants.defaultBarCount, 64);
  });

  test('AudioUtils functions', () {
    final normalized = AudioUtils.normalizeAmplitude(0.5);
    expect(normalized, isA<double>());
    expect(normalized >= 0.0, true);
    expect(normalized <= 1.0, true);

    final smoothedCorrect = AudioUtils.smoothValue(0.8, 0.2, 0.5);
    expect(smoothedCorrect, 0.5);
  });

  test('FFTUtils functions', () {
    final frequency = FFTUtils.binToFrequency(10, 44100, 1024);
    expect(frequency, isA<double>());
    expect(frequency > 0, true);

    final bin = FFTUtils.frequencyToBin(440, 44100, 1024);
    expect(bin, isA<int>());
    expect(bin >= 0, true);
  });

  test('Controllers creation', () {
    final audioController = AudioController();
    final visualizationController = VisualizationController();

    expect(audioController, isA<AudioController>());
    expect(visualizationController, isA<VisualizationController>());
    expect(audioController.isActive, false);
    expect(visualizationController.isActive, false);
  });
}
