import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelAnimationScreen extends StatefulWidget {
  const ModelAnimationScreen({super.key});

  @override
  State<ModelAnimationScreen> createState() => _ModelAnimationScreenState();
}

class _ModelAnimationScreenState extends State<ModelAnimationScreen> {
  // Your list of animation names. We use it to create the right number of buttons.
  final List<String> animationNames = const [
    'close-lid-1',
    'open-lid-1',
    'lid-2-close',
    'lid-2-open',
    'drawer-close',
    'drawer-open',
  ];

  // MODIFICATION: We now use an integer index to control the animation.
  int? _currentAnimationIndex;

  @override
  Widget build(BuildContext context) {
    final currentAnimationName =
        _currentAnimationIndex == null
            ? 'none'
            : animationNames[_currentAnimationIndex!];
    print('Building with animation: $currentAnimationName');

    return Scaffold(
      appBar: AppBar(title: const Text('Animation Debugger'), elevation: 2),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              key: ObjectKey(currentAnimationName),
              src: 'assets/glb/animation.glb',
              alt: 'A 3D model with animations',

              // MODIFICATION: Use `animationIndex` instead of `animationName`.
              animationName:
                  _currentAnimationIndex == null
                      ? null
                      : animationNames[_currentAnimationIndex!],

              cameraControls: true,
              autoRotate: _currentAnimationIndex == null,
              disableZoom: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Buttons to play animations by index
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children:
                      animationNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value;
                        return ElevatedButton(
                          onPressed: () {
                            print('Button clicked: $name (Index: $index)');
                            // MODIFICATION: Set the state with the button's index.
                            setState(() {
                              _currentAnimationIndex = index;
                            });
                          },
                          child: Text('$name (Index: $index)'),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 10),
                // A button to stop the animation
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    print('Stop Animation button clicked');
                    setState(() {
                      _currentAnimationIndex = null;
                    });
                  },
                  child: const Text('Stop Animation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
