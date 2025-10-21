import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'three_d_page_dashboard.dart';

class Flutter3DAnimationScreen extends StatefulWidget {
  const Flutter3DAnimationScreen({super.key});

  @override
  State<Flutter3DAnimationScreen> createState() =>
      _Flutter3DAnimationScreenState();
}

class _Flutter3DAnimationScreenState extends State<Flutter3DAnimationScreen> {
  // Create controller object to control 3D model
  Flutter3DController controller = Flutter3DController();

  // Track animation states
  bool isAnimationPlaying = false;
  String? currentAnimation;

  // Track component states (open/closed)
  bool isLid1Open = false;
  bool isLid2Open = false;
  bool isDrawerOpen = false;

  void _playAnimation(String animationName) {
    if (isAnimationPlaying) {
      print('Animation already playing, ignoring request');
      return;
    }

    print('Playing $animationName animation');

    setState(() {
      isAnimationPlaying = true;
      currentAnimation = animationName;
    });

    // Play the animation
    controller.playAnimation(animationName: animationName, loopCount: 1);

    // Pause after a brief moment to keep the final state
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        controller.pauseAnimation();
        _updateComponentState(animationName);

        setState(() {
          isAnimationPlaying = false;
          currentAnimation = null;
        });
      }
    });
  }

  void _updateComponentState(String animationName) {
    switch (animationName) {
      case 'open-lid-1':
        isLid1Open = true;
        break;
      case 'close-lid-1':
        isLid1Open = false;
        break;
      case 'lid-2-open':
        isLid2Open = true;
        break;
      case 'lid-2-close':
        isLid2Open = false;
        break;
      case 'drawer-open':
        isDrawerOpen = true;
        break;
      case 'drawer-close':
        isDrawerOpen = false;
        break;
    }
  }

  bool _isButtonEnabled(String component) {
    // Disable all buttons if any animation is playing
    if (isAnimationPlaying) return false;

    // If any component is open, only allow closing that component
    if (isLid1Open && component != 'lid1') return false;
    if (isLid2Open && component != 'lid2') return false;
    if (isDrawerOpen && component != 'drawer') return false;

    return true;
  }

  Color _getButtonColor(String component) {
    if (!_isButtonEnabled(component)) {
      return Colors.grey;
    }

    bool isOpen = false;
    switch (component) {
      case 'lid1':
        isOpen = isLid1Open;
        break;
      case 'lid2':
        isOpen = isLid2Open;
        break;
      case 'drawer':
        isOpen = isDrawerOpen;
        break;
    }

    if (currentAnimation?.contains(component) == true) {
      return Colors.blue;
    }
    return isOpen ? Colors.red : Colors.green;
  }

  String _getButtonText(String component) {
    bool isOpen = false;
    switch (component) {
      case 'lid1':
        isOpen = isLid1Open;
        break;
      case 'lid2':
        isOpen = isLid2Open;
        break;
      case 'drawer':
        isOpen = isDrawerOpen;
        break;
    }

    String componentName = '';
    switch (component) {
      case 'lid1':
        componentName = 'Lid 1';
        break;
      case 'lid2':
        componentName = 'Lid 2';
        break;
      case 'drawer':
        componentName = 'Drawer';
        break;
    }

    return isOpen ? 'Close $componentName' : 'Open $componentName';
  }

  Widget _buildToggleButton(String component) {
    final isEnabled = _isButtonEnabled(component);
    final buttonColor = _getButtonColor(component);
    final buttonText = _getButtonText(component);

    return ElevatedButton(
      onPressed: isEnabled ? () => _toggleComponent(component) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        minimumSize: const Size(120, 50),
      ),
      child: Text(buttonText),
    );
  }

  void _toggleComponent(String component) {
    String animationName = '';
    switch (component) {
      case 'lid1':
        animationName = isLid1Open ? 'close-lid-1' : 'open-lid-1';
        break;
      case 'lid2':
        animationName = isLid2Open ? 'lid-2-close' : 'lid-2-open';
        break;
      case 'drawer':
        animationName = isDrawerOpen ? 'drawer-close' : 'drawer-open';
        break;
    }

    _playAnimation(animationName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 3D Viewer'), elevation: 2),
      body: Stack(
        children: [
          Column(
            children: [
              // 3D Viewer
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Flutter3DViewer(
                    controller: controller,
                    src: 'assets/glb/new_test.glb',
                  ),
                ),
              ),

              // Animation Buttons
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleButton('lid1'),
                    const SizedBox(width: 16),
                    _buildToggleButton('lid2'),
                    const SizedBox(width: 16),
                    _buildToggleButton('drawer'),
                  ],
                ),
              ),
            ],
          ),

          // Dashboard in top-left corner
          const Positioned(top: 16, left: 16, child: ThreeDPageDashboard()),
        ],
      ),
    );
  }
}
