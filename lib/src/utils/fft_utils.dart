import 'dart:math' as math;

/// Utility functions for Fast Fourier Transform (FFT) operations.
class FFTUtils {
  /// Performs FFT on the given input data.
  /// Returns the magnitude spectrum.
  static List<double> performFFT(List<double> input) {
    final int n = input.length;
    if (n == 0) return [];

    // Ensure input length is a power of 2
    final int paddedLength = _nextPowerOf2(n);
    final List<double> paddedInput = List.filled(paddedLength, 0.0);
    for (int i = 0; i < n; i++) {
      paddedInput[i] = input[i];
    }

    // Perform FFT
    final List<Complex> fftResult = _fft(paddedInput);

    // Calculate magnitude spectrum
    final List<double> magnitude = List.filled(paddedLength ~/ 2, 0.0);
    for (int i = 0; i < magnitude.length; i++) {
      magnitude[i] = fftResult[i].magnitude;
    }

    return magnitude;
  }

  /// Applies Hanning window to reduce spectral leakage.
  static List<double> applyHanningWindow(List<double> input) {
    final List<double> windowed = List.filled(input.length, 0.0);
    for (int i = 0; i < input.length; i++) {
      final double window =
          0.5 - 0.5 * math.cos(2 * math.pi * i / (input.length - 1));
      windowed[i] = input[i] * window;
    }
    return windowed;
  }

  /// Converts frequency bin index to actual frequency.
  static double binToFrequency(int binIndex, int sampleRate, int fftSize) {
    return binIndex * sampleRate / fftSize;
  }

  /// Converts frequency to bin index.
  static int frequencyToBin(double frequency, int sampleRate, int fftSize) {
    return (frequency * fftSize / sampleRate).round();
  }

  /// Finds the peak frequency in the spectrum.
  static double findPeakFrequency(
      List<double> spectrum, int sampleRate, int fftSize) {
    if (spectrum.isEmpty) return 0.0;

    int maxIndex = 0;
    double maxValue = spectrum[0];

    for (int i = 1; i < spectrum.length; i++) {
      if (spectrum[i] > maxValue) {
        maxValue = spectrum[i];
        maxIndex = i;
      }
    }

    return binToFrequency(maxIndex, sampleRate, fftSize);
  }

  /// Calculates the spectral centroid (center of mass of the spectrum).
  static double calculateSpectralCentroid(
      List<double> spectrum, int sampleRate, int fftSize) {
    if (spectrum.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < spectrum.length; i++) {
      final frequency = binToFrequency(i, sampleRate, fftSize);
      final weight = spectrum[i];
      weightedSum += frequency * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  /// Applies smoothing to the spectrum to reduce noise.
  static List<double> smoothSpectrum(
      List<double> spectrum, double smoothingFactor) {
    if (spectrum.isEmpty) return [];

    final List<double> smoothed = List.filled(spectrum.length, 0.0);
    smoothed[0] = spectrum[0];

    for (int i = 1; i < spectrum.length; i++) {
      smoothed[i] = smoothingFactor * spectrum[i] +
          (1 - smoothingFactor) * smoothed[i - 1];
    }

    return smoothed;
  }

  /// Finds the next power of 2 greater than or equal to n.
  static int _nextPowerOf2(int n) {
    if (n <= 1) return 1;

    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Performs the actual FFT computation.
  static List<Complex> _fft(List<double> input) {
    final int n = input.length;
    if (n == 1) return [Complex(input[0], 0)];

    // Split into even and odd indices
    final List<double> even = <double>[];
    final List<double> odd = <double>[];

    for (int i = 0; i < n; i++) {
      if (i % 2 == 0) {
        even.add(input[i]);
      } else {
        odd.add(input[i]);
      }
    }

    // Recursively compute FFT
    final List<Complex> evenFFT = _fft(even);
    final List<Complex> oddFFT = _fft(odd);

    // Combine results
    final List<Complex> result = List.filled(n, const Complex.zero());
    for (int k = 0; k < n ~/ 2; k++) {
      final double angle = -2 * math.pi * k / n;
      final Complex twiddle = Complex(math.cos(angle), math.sin(angle));
      final Complex oddTerm = oddFFT[k] * twiddle;

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
  const Complex.zero()
      : real = 0.0,
        imaginary = 0.0;

  /// Real part of the complex number.
  final double real;

  /// Imaginary part of the complex number.
  final double imaginary;

  /// Magnitude (absolute value) of the complex number.
  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  /// Phase (argument) of the complex number.
  double get phase => math.atan2(imaginary, real);

  /// Addition of complex numbers.
  Complex operator +(Complex other) {
    return Complex(real + other.real, imaginary + other.imaginary);
  }

  /// Subtraction of complex numbers.
  Complex operator -(Complex other) {
    return Complex(real - other.real, imaginary - other.imaginary);
  }

  /// Multiplication of complex numbers.
  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  /// Division of complex numbers.
  Complex operator /(Complex other) {
    final double denominator =
        other.real * other.real + other.imaginary * other.imaginary;
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }

  @override
  String toString() => 'Complex($real, $imaginary)';
}
