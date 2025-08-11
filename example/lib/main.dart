import 'package:flutter/material.dart';
import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';

void main() {
  runApp(const AudioVisualizerApp());
}

/// Main application demonstrating the audio visualizer package.
class AudioVisualizerApp extends StatelessWidget {
  /// Creates an instance of [AudioVisualizerApp].
  const AudioVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Visualizer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AudioVisualizerDemo(),
    );
  }
}

/// Demo page showing different visualization types.
class AudioVisualizerDemo extends StatefulWidget {
  /// Creates an instance of [AudioVisualizerDemo].
  const AudioVisualizerDemo({super.key});

  @override
  State<AudioVisualizerDemo> createState() => _AudioVisualizerDemoState();
}

class _AudioVisualizerDemoState extends State<AudioVisualizerDemo> {
  VisualizationType _currentType = VisualizationType.waveform;
  bool _isPlaying = false;

  final AudioVisualizerStyle _style = const AudioVisualizerStyle(
    waveformColor: Colors.blue,
    spectrumColor: Colors.green,
    backgroundColor: Colors.black87,
    barWidth: 4.0,
    barSpacing: 2.0,
    animationDuration: Duration(milliseconds: 200),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Visualizer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visualization type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visualization Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: VisualizationType.values.map((type) {
                        return ChoiceChip(
                          label: Text(type.name.toUpperCase()),
                          selected: _currentType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _currentType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Audio visualizer
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currentType.name.toUpperCase()} Visualization',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AudioVisualizer(
                          visualizationType: _currentType,
                          style: _style,
                          height: 300,
                          onDataReceived: (data) {
                            // Handle audio data
                            if (_isPlaying) {
                              print('Audio data: ${data.amplitude}');
                            }
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentType = VisualizationType.values[
                              (_currentType.index + 1) %
                                  VisualizationType.values.length];
                        });
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Next Type'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
