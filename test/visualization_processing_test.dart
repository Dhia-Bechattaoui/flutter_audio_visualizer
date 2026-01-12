import 'package:flutter_audio_visualizer/src/controllers/visualization_controller.dart';
import 'package:flutter_audio_visualizer/src/enums/visualization_type.dart';
import 'package:flutter_audio_visualizer/src/models/audio_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisualizationController Tests', () {
    late VisualizationController controller;

    setUp(() {
      controller = VisualizationController();
    });

    test('Initial state is empty', () {
      expect(controller.isActive, false);
      expect(controller.visualizationType, VisualizationType.waveform);
    });

    test('updateData generates visualization bars', () async {
      controller.start();
      final now = DateTime.now();
      final audioData = AudioData(
        amplitude: 0.5,
        frequency: 440,
        timestamp: now,
        spectrum: List.filled(64, 0.1),
      );

      final expectation = expectLater(
        controller.visualizationDataStream,
        emits(
          predicate((final data) {
            if (data is! VisualizationData) {
              return false;
            }
            return data.bars.length == 64 && data.bars.any((final b) => b > 0);
          }),
        ),
      );

      controller.updateData(audioData);
      await expectation;
    });

    test('Temporal smoothing reduces jumping', () async {
      controller.start();
      final now = DateTime.now();

      // First update
      final data1 = AudioData(
        amplitude: 0.1,
        frequency: 440,
        timestamp: now,
        spectrum: List.filled(64, 0.01),
      );

      // Second update with a massive spike
      final data2 = AudioData(
        amplitude: 0.9,
        frequency: 440,
        timestamp: now.add(const Duration(milliseconds: 20)),
        spectrum: List.filled(64, 0.8),
      );

      final results = <VisualizationData>[];
      final sub = controller.visualizationDataStream.listen(results.add);

      controller
        ..updateData(data1)
        ..updateData(data2);

      // Wait a bit for processing
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(results.length, 2);

      // Due to smoothing factor 0.4:
      // prev + (new - prev) * (1 - 0.4) = 0 + (spike - 0) * 0.6
      // So it should be around 0.6 * raw value, not the full raw value
      // immediately.
      expect(results[1].bars[0], lessThan(1.0));

      await sub.cancel();
    });
  });
}
