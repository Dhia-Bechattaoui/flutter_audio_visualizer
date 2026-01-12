import 'dart:math' as math;

/// Utility class providing high-performance Fast Fourier Transform (FFT)
/// operations.
///
/// Use this class to convert time-domain audio signals into the frequency
/// domain for spectral visualization.
class FFTUtils {
  // Prevent instantiation
  const FFTUtils._();

  /// Performs a Fast Fourier Transform on the given [input] data.
  ///
  /// The input size must be a power of 2 (it will be padded automatically).
  /// Returns a list of magnitudes for the frequency bins.
  static List<double> performFFT(final List<double> input) {
    final n = input.length;
    if (n == 0) {
      return [];
    }

    // Ensure input length is a power of 2
    final paddedLength = _nextPowerOf2(n);
    final paddedInput = List<double>.filled(paddedLength, 0);
    for (var i = 0; i < n; i++) {
      paddedInput[i] = input[i];
    }

    // Perform FFT
    final fftResult = _fft(paddedInput);

    // Calculate magnitude spectrum
    final magnitude = List<double>.filled(paddedLength ~/ 2, 0);
    for (var i = 0; i < magnitude.length; i++) {
      magnitude[i] = fftResult[i].magnitude / paddedLength;
    }

    return magnitude;
  }

  /// Applies a Hanning window to the [input] data to reduce spectral leakage.
  ///
  /// This is typically called before performing an FFT to improve the
  /// frequency-domain resolution and reduce artifacts.
  static List<double> applyHanningWindow(final List<double> input) {
    final windowed = List<double>.filled(input.length, 0);
    for (var i = 0; i < input.length; i++) {
      final window = 0.5 - 0.5 * math.cos(2 * math.pi * i / (input.length - 1));
      windowed[i] = input[i] * window;
    }
    return windowed;
  }

  /// Converts a frequency bin index into its corresponding actual
  /// frequency in Hz.
  static double binToFrequency(
    final int binIndex,
    final int sampleRate,
    final int fftSize,
  ) => binIndex * sampleRate / fftSize;

  /// Converts frequency to bin index.
  static int frequencyToBin(
    final double frequency,
    final int sampleRate,
    final int fftSize,
  ) => (frequency * fftSize / sampleRate).round();

  /// Finds the peak frequency in the spectrum.
  static double findPeakFrequency(
    final List<double> spectrum,
    final int sampleRate,
    final int fftSize,
  ) {
    if (spectrum.isEmpty) {
      return 0;
    }

    var maxIndex = 0;
    var maxValue = spectrum[0];

    for (var i = 1; i < spectrum.length; i++) {
      if (spectrum[i] > maxValue) {
        maxValue = spectrum[i];
        maxIndex = i;
      }
    }

    return binToFrequency(maxIndex, sampleRate, fftSize);
  }

  /// Calculates the spectral centroid (center of mass of the spectrum).
  static double calculateSpectralCentroid(
    final List<double> spectrum,
    final int sampleRate,
    final int fftSize,
  ) {
    if (spectrum.isEmpty) {
      return 0;
    }

    var weightedSum = 0.0;
    var totalWeight = 0.0;

    for (var i = 0; i < spectrum.length; i++) {
      final frequency = binToFrequency(i, sampleRate, fftSize);
      final weight = spectrum[i];
      weightedSum += frequency * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  /// Applies smoothing to the spectrum to reduce noise.
  static List<double> smoothSpectrum(
    final List<double> spectrum,
    final double smoothingFactor,
  ) {
    if (spectrum.isEmpty) {
      return [];
    }

    final smoothed = List<double>.filled(spectrum.length, 0);
    smoothed[0] = spectrum[0];

    for (var i = 1; i < spectrum.length; i++) {
      smoothed[i] =
          smoothingFactor * spectrum[i] +
          (1 - smoothingFactor) * smoothed[i - 1];
    }

    return smoothed;
  }

  /// Finds the next power of 2 greater than or equal to n.
  static int _nextPowerOf2(final int n) {
    if (n <= 1) {
      return 1;
    }

    var power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Performs the actual FFT computation.
  static List<Complex> _fft(final List<double> input) {
    final n = input.length;
    if (n == 1) {
      return [Complex(input[0], 0)];
    }

    // Split into even and odd indices
    final even = <double>[];
    final odd = <double>[];

    for (var i = 0; i < n; i++) {
      if (i.isEven) {
        even.add(input[i]);
      } else {
        odd.add(input[i]);
      }
    }

    // Recursively compute FFT
    final evenFFT = _fft(even);
    final oddFFT = _fft(odd);

    // Combine results
    final result = List<Complex>.filled(n, const Complex.zero());
    for (var k = 0; k < n ~/ 2; k++) {
      final angle = -2 * math.pi * k / n;
      final twiddle = Complex(math.cos(angle), math.sin(angle));
      final oddTerm = oddFFT[k] * twiddle;

      result[k] = evenFFT[k] + oddTerm;
      result[k + n ~/ 2] = evenFFT[k] - oddTerm;
    }

    return result;
  }
}

/// Complex number class for FFT calculations.
class Complex {
  /// Creates a complex number with the given real and imaginary parts.
  const Complex(this.real, this.imaginary);

  /// Creates a complex number with zero real and imaginary parts.
  const Complex.zero() : real = 0.0, imaginary = 0.0;

  /// Real part of the complex number.
  final double real;

  /// Imaginary part of the complex number.
  final double imaginary;

  /// Magnitude (absolute value) of the complex number.
  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  /// Phase (argument) of the complex number.
  double get phase => math.atan2(imaginary, real);

  /// Addition of complex numbers.
  Complex operator +(final Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  /// Subtraction of complex numbers.
  Complex operator -(final Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  /// Multiplication of complex numbers.
  Complex operator *(final Complex other) => Complex(
    real * other.real - imaginary * other.imaginary,
    real * other.imaginary + imaginary * other.real,
  );

  /// Division of complex numbers.
  Complex operator /(final Complex other) {
    final denominator =
        other.real * other.real + other.imaginary * other.imaginary;
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }

  @override
  String toString() => 'Complex($real, $imaginary)';
}
