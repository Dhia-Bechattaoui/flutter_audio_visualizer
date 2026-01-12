# Flutter Audio Visualizer

[![Pub Version](https://img.shields.io/pub/v/flutter_audio_visualizer)](https://pub.dev/packages/flutter_audio_visualizer)
[![Flutter Version](https://img.shields.io/badge/flutter-3.32+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/dart-3.8+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform Support](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20WASM%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](https://flutter.dev/multi-platform)

A powerful Flutter package for real-time audio visualization with customizable waveforms and spectrums. Perfect for music apps, audio players, and any application requiring audio visualization.

<p align="center">
  <img src="https://raw.githubusercontent.com/Dhia-Bechattaoui/flutter_audio_visualizer/main/doc/assets/demo.gif" width="300" alt="Audio Visualizer Demo">
</p>

## Features

🎵 **Real-time Audio Visualization**
- Live waveform display
- Spectrum analyzer with FFT
- **Adaptive Noise Gate** for clean silence
- **Auto Gain Control (AGC)** for consistent levels
- Customizable visualization styles
- High-performance rendering

🎨 **Customizable UI**
- Multiple visualization modes
- Color schemes and themes
- Responsive design
- Cross-platform compatibility

⚡ **High Performance**
- Optimized audio processing
- Efficient memory usage
- Smooth 60fps rendering
- Background audio support

🌐 **Multi-Platform Support**
- Android (API 21+)
- iOS (12.0+)
- Web
- **WASM compatible**
- Windows
- macOS
- Linux

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_audio_visualizer: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';

class AudioVisualizerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Visualizer')),
      body: Center(
        child: AudioVisualizer(
          audioSource: AudioSource.microphone,
          visualizationType: VisualizationType.waveform,
          onDataReceived: (data) {
            // Handle audio data
          },
        ),
      ),
    );
  }
}
```

### Advanced Configuration

```dart
AudioVisualizer(
  audioSource: AudioSource.audioPlayer,
  visualizationType: VisualizationType.spectrum,
  style: AudioVisualizerStyle(
    waveformColor: Colors.blue,
    backgroundColor: Colors.black,
    barWidth: 4.0,
    barSpacing: 2.0,
    animationDuration: Duration(milliseconds: 300),
  ),
  onDataReceived: (data) {
    // Process FFT data
    print('Frequency: ${data.frequency}Hz, Amplitude: ${data.amplitude}');
  },
  onError: (error) {
    print('Visualization error: $error');
  },
)
```

## API Reference

### AudioVisualizer

The main widget for audio visualization.

#### Properties

- `audioSource`: Source of audio data (microphone, audio player, custom)
- `visualizationType`: Type of visualization (waveform, spectrum, both)
- `style`: Customization options for appearance
- `onDataReceived`: Callback for audio data
- `onError`: Error handling callback

### AudioVisualizerStyle

Configuration for visual appearance.

```dart
AudioVisualizerStyle(
  waveformColor: Colors.blue,
  backgroundColor: Colors.transparent,
  barWidth: 3.0,
  barSpacing: 1.0,
  animationDuration: Duration(milliseconds: 200),
  gradient: LinearGradient(
    colors: [Colors.blue, Colors.purple],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
)
```

### Visualization Types

- **Waveform**: Real-time amplitude visualization
- **Spectrum**: Frequency domain analysis
- **Combined**: Both waveform and spectrum

## Examples

### Music Player Integration

```dart
class MusicPlayerVisualizer extends StatefulWidget {
  @override
  _MusicPlayerVisualizerState createState() => _MusicPlayerVisualizerState();
}

class _MusicPlayerVisualizerState extends State<MusicPlayerVisualizer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AudioVisualizer(
          audioSource: AudioSource.audioPlayer,
          audioPlayer: _audioPlayer,
          visualizationType: VisualizationType.combined,
          style: AudioVisualizerStyle(
            waveformColor: Colors.green,
            spectrumColor: Colors.blue,
            backgroundColor: Colors.black87,
          ),
        ),
        // Audio controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _audioPlayer.play(),
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () => _audioPlayer.pause(),
            ),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: () => _audioPlayer.stop(),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Microphone Input

```dart
AudioVisualizer(
  audioSource: AudioSource.microphone,
  visualizationType: VisualizationType.waveform,
  style: AudioVisualizerStyle(
    waveformColor: Colors.red,
    backgroundColor: Colors.grey[900],
    barWidth: 2.0,
    barSpacing: 1.0,
  ),
  onDataReceived: (data) {
    // Handle microphone data
    if (data.amplitude > 0.8) {
      // High volume detected
    }
  },
)
```

## Platform-Specific Setup

### Android

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

### iOS

Add permissions to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for audio visualization.</string>
```

### Web

No additional setup required. The package works out of the box with Flutter web.

## Performance Tips

1. **Use appropriate visualization type**: Choose waveform for simple amplitude display or spectrum for frequency analysis
2. **Optimize update frequency**: Adjust `animationDuration` based on your needs
3. **Background processing**: Use `compute()` for heavy FFT calculations
4. **Memory management**: Dispose of controllers properly

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Testing

Run the test suite:

```bash
flutter test
```

Generate coverage report:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](https://github.com/Dhia-Bechattaoui/flutter_audio_visualizer#readme)
- 🐛 [Issue Tracker](https://github.com/Dhia-Bechattaoui/flutter_audio_visualizer/issues)
- 💬 [Discussions](https://github.com/Dhia-Bechattaoui/flutter_audio_visualizer/discussions)
- 📧 [Email Support](mailto:support@example.com)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete list of changes.

## Acknowledgments

- Flutter team for the amazing framework
- Audio processing community for algorithms and insights
- Contributors and users for feedback and suggestions

---

Made with ❤️ by [Dhia Bechattaoui](https://github.com/Dhia-Bechattaoui)
