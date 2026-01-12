import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../models/audio_data.dart';
import '../models/audio_source.dart';
import '../utils/fft_utils.dart';

/// Controller for managing audio sources and data processing.
///
/// This class handles the lifecycle of an [AudioSource], processes raw audio
/// data through a high-performance signal processing pipeline, and emits
/// [AudioData] for real-time visualization.
///
/// The processing pipeline includes:
/// * **DC Offset Removal**: Centers the signal.
/// * **High-Pass Filter (HPF)**: Removes low-frequency rumble.
/// * **Auto Gain Control (AGC)**: Normalizes levels dynamically.
/// * **Adaptive Noise Gate**: Aggressively silences background noise.
class AudioController {
  /// Creates an instance of [AudioController] with an optional [audioSource].
  AudioController({final AudioSource? audioSource})
    : _audioSource = audioSource;

  AudioSource? _audioSource;
  StreamSubscription<List<int>>? _sourceSubscription;
  bool _isActive = false;
  Future<void>? _currentOperation;

  // Signal processing state
  double _lastX = 0;
  double _lastY = 0;
  double _peakHistory = 0.1; // Rolling peak for AGC

  /// Stream controller for audio data
  final StreamController<AudioData> _audioDataController =
      StreamController<AudioData>.broadcast();

  /// Stream of audio data
  Stream<AudioData> get audioDataStream => _audioDataController.stream;

  /// Whether the audio controller is currently active
  bool get isActive => _isActive;

  /// The current audio source.
  AudioSource? get audioSource => _audioSource;

  /// Sets the audio source for this controller.
  ///
  /// If the controller is active, it will stop the current source and
  /// switch to the new one.
  void setAudioSource(final AudioSource audioSource) {
    if (_isActive) {
      unawaited(stop());
    }
    _audioSource = audioSource;
  }

  /// Starts the audio controller and begins processing the audio stream.
  ///
  /// This method requests the [AudioSource] to start and sets up a subscription
  /// to its data stream. It uses internal serialization to prevent race
  /// conditions if [start] or [stop] are called concurrently.
  Future<void> start() async {
    // Serialization to prevent race conditions
    final previousOp = _currentOperation;
    final completer = Completer<void>();
    _currentOperation = completer.future;

    try {
      if (previousOp != null) {
        await previousOp;
      }

      if (_isActive || _audioSource == null) {
        return;
      }

      await _audioSource!.start();
      _isActive = true;

      // Subscribe to real audio stream if available
      if (_audioSource!.stream != null) {
        _sourceSubscription = _audioSource!.stream!.listen(
          _processRawAudioData,
          onError: (final Object error) {
            // print('Audio source error: $error');
          },
        );
      }
    } catch (e) {
      _isActive = false;
      rethrow;
    } finally {
      completer.complete();
    }
  }

  /// Stops the audio controller.
  ///
  /// Cancels the subscription to the audio source and stops the [AudioSource]
  /// itself. Like [start], this method is serialized.
  Future<void> stop() async {
    // Serialization to prevent race conditions
    final previousOp = _currentOperation;
    final completer = Completer<void>();
    _currentOperation = completer.future;

    try {
      if (previousOp != null) {
        await previousOp;
      }

      if (!_isActive) {
        return;
      }

      await _sourceSubscription?.cancel();
      _sourceSubscription = null;

      if (_audioSource != null) {
        await _audioSource!.stop();
      }

      _isActive = false;
    } finally {
      completer.complete();
    }
  }

  /// Processes raw audio samples
  void _processRawAudioData(final List<int> rawSamples) {
    if (rawSamples.isEmpty) {
      return;
    }

    // Switched to ByteData for robust endianness handling (Big Endian detected)
    final bytes = rawSamples is Uint8List
        ? rawSamples
        : Uint8List.fromList(rawSamples);
    final byteData = ByteData.sublistView(bytes);
    final normalizedSamples = <double>[];

    for (var i = 0; i < byteData.lengthInBytes - 1; i += 2) {
      try {
        // Based on user logs [255, 127]...
        // LE [127, 255] is quiet (just offset). BE [255, 127] is massive noise.
        // Reverting to Little Endian as it's the standard for this recorder.
        final sample = byteData.getInt16(i, Endian.little);
        normalizedSamples.add(sample / 32768.0);
      } on Exception catch (_) {
        break;
      }
    }

    if (normalizedSamples.isEmpty) {
      return;
    }

    try {
      final now = DateTime.now();

      // 1. Calculate Mean (DC Offset)
      var sum = 0.0;
      for (final sample in normalizedSamples) {
        sum += sample;
      }
      final mean = sum / normalizedSamples.length;

      // 2. High-Pass Filter (remove rumble/hum) and DC Removal
      // 3. Auto Gain Control (AGC) tracking
      final filteredSamples = <double>[];
      var localPeak = 0.001;

      for (final rawSample in normalizedSamples) {
        // DC offset removal first
        final x = rawSample - mean;

        // Simple IIR High-Pass Filter (approx 80Hz at 44.1kHz)
        final y = 0.98 * (_lastY + x - _lastX);
        _lastX = x;
        _lastY = y;

        filteredSamples.add(y);
        localPeak = math.max(localPeak, y.abs());
      }

      // Smooth peak history for AGC (very slow tracking to preserve dynamics)
      _peakHistory = _peakHistory * 0.98 + localPeak * 0.02;

      // 4. Noise Gate & AGC Logic
      const noiseThreshold = 0.025; // Higher threshold to kill room noise
      const maxGain = 20.0; // Allow more boost for speech

      var gain = 0.5 / math.max(0.001, _peakHistory);

      // Apply Gain Limit
      if (gain > maxGain) {
        gain = maxGain;
      }

      // Apply Noise Gate (Aggressive)
      if (_peakHistory < noiseThreshold) {
        // Squared factor for steeper cut-off
        final gateFactor = math
            .pow(_peakHistory / noiseThreshold, 2)
            .toDouble();
        gain *= gateFactor;
      }

      final agcSamples = <double>[];
      var sumSquares = 0.0;

      for (final s in filteredSamples) {
        final scaled = s * gain;
        agcSamples.add(scaled);
        sumSquares += scaled * scaled;
      }

      final amplitude = math.sqrt(sumSquares / agcSamples.length);

      // Perform FFT to get spectrum
      var spectrum = <double>[];
      var peakFrequency = 0.0;

      if (agcSamples.length >= 64) {
        var fftInput = agcSamples;
        if (fftInput.length > 1024) {
          fftInput = fftInput.sublist(fftInput.length - 1024);
        }

        final windowed = FFTUtils.applyHanningWindow(fftInput);
        spectrum = FFTUtils.performFFT(windowed);

        if (spectrum.isNotEmpty) {
          peakFrequency = FFTUtils.findPeakFrequency(
            spectrum,
            44100,
            fftInput.length,
          );
        }
      }

      final audioData = AudioData(
        amplitude: amplitude,
        frequency: peakFrequency,
        timestamp: now,
        spectrum: spectrum,
      );

      _audioDataController.add(audioData);
    } on Exception catch (_) {
      // print('Error processing audio data: $e');
    }
  }

  /// Disposes of the controller and cleans up resources.
  ///
  /// Closes the audio data stream and disposes of the [AudioSource].
  void dispose() {
    unawaited(stop());
    unawaited(_audioDataController.close());
    _audioSource?.dispose();
  }
}
