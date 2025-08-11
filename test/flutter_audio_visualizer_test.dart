import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';

void main() {
  test('Basic enum tests', () {
    // Test visualization types
    expect(VisualizationType.values.length, 3);
    expect(isA<VisualizationType>(VisualizationType.waveform), true);
    expect(isA<VisualizationType>(VisualizationType.spectrum), true);
    expect(isA<VisualizationType>(VisualizationType.combined), true);

    // Test audio source types
    expect(AudioSourceType.values.length, 5);
    expect(isA<AudioSourceType>(AudioSourceType.microphone), true);
    expect(isA<AudioSourceType>(AudioSourceType.audioPlayer), true);
  });

  test('AudioData creation', () {
    final now = DateTime.now();
    final audioData = AudioData(
      amplitude: 0.5,
      frequency: 440.0,
      timestamp: now,
    );

    expect(audioData.amplitude, 0.5);
    expect(audioData.frequency, 440.0);
    expect(audioData.timestamp, now);
  });

  test('AudioData copyWith', () {
    final original = AudioData(
      amplitude: 0.5,
      frequency: 440.0,
      timestamp: DateTime.now(),
    );

    final modified = original.copyWith(amplitude: 0.8);
    expect(modified.amplitude, 0.8);
    expect(modified.frequency, original.frequency);
  });

  test('AudioVisualizerStyle creation', () {
    const style = AudioVisualizerStyle(
      barWidth: 3.0,
      barSpacing: 1.0,
    );

    expect(style.barWidth, 3.0);
    expect(style.barSpacing, 1.0);
  });

  test('AudioVisualizerStyle copyWith', () {
    const original = AudioVisualizerStyle();
    final modified = original.copyWith(barWidth: 5.0);

    expect(modified.barWidth, 5.0);
    expect(modified.waveformColor, original.waveformColor);
  });

  test('AudioSource properties', () {
    const microphoneSource = MicrophoneAudioSource();
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
    expect(isA<double>(normalized), true);
    expect(normalized >= 0.0, true);
    expect(normalized <= 1.0, true);

    final smoothed = AudioUtils.smoothValue(0.8, 0.2, 0.5);
    expect(smoothed, 0.5);
  });

  test('FFTUtils functions', () {
    final frequency = FFTUtils.binToFrequency(10, 44100, 1024);
    expect(isA<double>(frequency), true);
    expect(frequency > 0, true);

    final bin = FFTUtils.frequencyToBin(440.0, 44100, 1024);
    expect(isA<int>(bin), true);
    expect(bin >= 0, true);
  });

  test('Controllers creation', () {
    final audioController = AudioController();
    final visualizationController = VisualizationController();

    expect(isA<AudioController>(audioController), true);
    expect(isA<VisualizationController>(visualizationController), true);
    expect(audioController.isActive, false);
    expect(visualizationController.isActive, false);
  });
}

// Simple test framework
void test(String description, Function testFunction) {
  print('Running test: $description');
  try {
    testFunction();
    print('✓ Test passed: $description');
  } catch (e) {
    print('✗ Test failed: $description - $e');
  }
}

void expect(dynamic actual, dynamic matcher) {
  if (actual == matcher) {
    return;
  }
  throw Exception('Expected $matcher but got $actual');
}

bool isA<T>(dynamic obj) {
  return obj is T;
}
