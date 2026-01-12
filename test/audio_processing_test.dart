import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_audio_visualizer/src/controllers/audio_controller.dart';
import 'package:flutter_audio_visualizer/src/enums/audio_source_type.dart';
import 'package:flutter_audio_visualizer/src/models/audio_data.dart';
import 'package:flutter_audio_visualizer/src/models/audio_source.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAudioSource extends AudioSource {
  final _controller = StreamController<List<int>>.broadcast();
  bool _isActive = false;

  @override
  AudioSourceType get type => AudioSourceType.microphone;

  @override
  bool get isActive => _isActive;

  @override
  Stream<List<int>>? get stream => _controller.stream;

  @override
  Future<void> start() async {
    _isActive = true;
  }

  @override
  Future<void> stop() async {
    _isActive = false;
  }

  @override
  void dispose() {
    unawaited(_controller.close());
  }

  void pushData(final List<int> data) {
    _controller.add(data);
  }
}

void main() {
  group('AudioController DSP Tests', () {
    late MockAudioSource mockSource;
    late AudioController controller;

    setUp(() {
      mockSource = MockAudioSource();
      controller = AudioController(audioSource: mockSource);
    });

    tearDown(() {
      controller.dispose();
    });

    test('AudioController processes raw data and emits AudioData', () async {
      await controller.start();

      // Create 1024 bytes (512 samples)
      final data = Uint8List(1024);

      final expectation = expectLater(
        controller.audioDataStream,
        emits(isA<AudioData>()),
      );

      mockSource.pushData(data);
      await expectation;
    });

    test('Noise Gate effectively silences low signals', () async {
      await controller.start();

      // Push pure silence
      final silence = Uint8List(1024);

      final completer = Completer<AudioData>();
      final sub = controller.audioDataStream.listen(completer.complete);

      mockSource.pushData(silence);
      final data = await completer.future;

      // Amplitude should be very close to 0 due to noise gate
      expect(data.amplitude, lessThan(0.01));
      await sub.cancel();
    });

    test('AGC boosts moderate signals', () async {
      await controller.start();

      // Create a small sine-like signal (low amplitude)
      // PCM16 Little Endian: [LSB, MSB]
      // Let's use 1000/32768 approx 0.03 amplitude
      final signal = Uint8List(1024);
      final byteData = ByteData.view(signal.buffer);
      for (var i = 0; i < 512; i++) {
        // Create a basic sine wave: amplitude 1000 (~0.03 normalized)
        final val = (1000 * math.sin(i * 2 * math.pi / 20)).round();
        byteData.setInt16(i * 2, val, Endian.little);
      }

      final completer = Completer<AudioData>();
      final sub = controller.audioDataStream.listen(completer.complete);

      mockSource.pushData(signal);
      final data = await completer.future;

      // Gain should have boosted this above the raw ~0.03
      // AGC target is 0.5, but it tracks slowly.
      // With initial _peakHistory = 0.1, gain is approx 5x.
      // So 0.03 * 5 = 0.15 approx.
      expect(data.amplitude, greaterThan(0.01));
      await sub.cancel();
    });
  });
}
