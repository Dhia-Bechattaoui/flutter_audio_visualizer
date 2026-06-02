# Flutter Audio Visualizer

[![Pub Version](https://img.shields.io/pub/v/flutter_audio_visualizer)](https://pub.dev/packages/flutter_audio_visualizer)
[![Flutter Version](https://img.shields.io/badge/flutter-3.32+-blue.svg)](https://flutter.dev/)
[![Platform Support](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20WASM%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](https://flutter.dev/multi-platform)

A Flutter package for real-time audio visualization with customizable waveforms and spectrums.

<p align="center">
  <img src="https://raw.githubusercontent.com/Dhia-Bechattaoui/flutter_audio_visualizer/main/assets/audio_visualizer.gif" width="300" alt="Flutter Audio Visualizer Showcase">
</p>

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_audio_visualizer: ^0.1.2
```

## Quick Start

```dart
import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';

// Basic microphone visualization
AudioVisualizer(
  audioSource: AudioSource.microphone,
  visualizationType: VisualizationType.waveform,
  onDataReceived: (data) {
    // Process audio data
  },
)
```

## Setup

**Android**  
Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

**iOS**  
Add the microphone usage description to your `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for audio visualization.</string>
```

**Web & Desktop**  
No additional setup is required.

## License

This project is licensed under the MIT License.
