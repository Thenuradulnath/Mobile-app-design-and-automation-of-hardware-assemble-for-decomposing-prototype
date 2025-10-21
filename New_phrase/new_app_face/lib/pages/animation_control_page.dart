// lib/pages/animation_control_page.dart
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AnimationControlPage extends StatefulWidget {
  const AnimationControlPage({Key? key}) : super(key: key);

  @override
  State<AnimationControlPage> createState() => _AnimationControlPageState();
}

class _AnimationControlPageState extends State<AnimationControlPage> {
  bool _loading = true;
  bool _autoRotate = false;
  String _currentAnimation = '';

  // Animation states for visual feedback
  final Map<String, bool> _animationStates = {
    'close-lid-1': false,
    'open-lid-1': false,
    'lid-2-close': false,
    'lid-2-open': false,
    'drawer-close': false,
    'drawer-open': false,
  };

  // Available animations with better icons and descriptions
  final List<Map<String, dynamic>> animations = [
    {
      'name': 'close-lid-1',
      'display': 'Close Lid 1',
      'icon': Icons.lock,
      'color': Colors.red,
      'description': 'Closes the first lid component',
    },
    {
      'name': 'open-lid-1',
      'display': 'Open Lid 1',
      'icon': Icons.lock_open,
      'color': Colors.green,
      'description': 'Opens the first lid component',
    },
    {
      'name': 'lid-2-close',
      'display': 'Close Lid 2',
      'icon': Icons.lock,
      'color': Colors.red,
      'description': 'Closes the second lid component',
    },
    {
      'name': 'lid-2-open',
      'display': 'Open Lid 2',
      'icon': Icons.lock_open,
      'color': Colors.green,
      'description': 'Opens the second lid component',
    },
    {
      'name': 'drawer-close',
      'display': 'Close Drawer',
      'icon': Icons.inbox,
      'color': Colors.orange,
      'description': 'Closes the drawer component',
    },
    {
      'name': 'drawer-open',
      'display': 'Open Drawer',
      'icon': Icons.outbox,
      'color': Colors.blue,
      'description': 'Opens the drawer component',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loading = true;

    // Fallback loader
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Controls'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
            onPressed: () => setState(() => _autoRotate = !_autoRotate),
            tooltip: 'Toggle Auto-rotate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAllAnimations,
            tooltip: 'Reset All Animations',
          ),
        ],
      ),
      body: Column(
        children: [
          // 3D Model Viewer
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    ModelViewer(
                      src: 'assets/glb/animation.glb',
                      alt: 'LIDA composter 3D model with animations',
                      ar: false,
                      autoRotate: _autoRotate,
                      autoPlay: false,
                      cameraControls: true,
                      disableZoom: false,
                      exposure: 1.0,
                      shadowIntensity: 1.0,
                      environmentImage: 'neutral',
                      animationName: _currentAnimation,
                      animationCrossfadeDuration: 300,
                    ),
                    if (_loading)
                      Container(
                        color: cs.surface.withOpacity(0.8),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    // Current animation indicator
                    if (_currentAnimation.isNotEmpty)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: cs.onPrimary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Playing: ${_getAnimationDisplayName(_currentAnimation)}',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Animation Controls
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animation Controls',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: animations.length,
                      itemBuilder: (context, index) {
                        final animation = animations[index];
                        return _buildAnimationButton(animation, cs);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationButton(Map<String, dynamic> animation, ColorScheme cs) {
    final isActive = _animationStates[animation['name']] ?? false;
    final isCurrentlyPlaying = _currentAnimation == animation['name'];

    return ElevatedButton(
      onPressed: () => _toggleAnimation(animation['name']!),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isCurrentlyPlaying
                ? animation['color']
                : isActive
                ? cs.primaryContainer
                : cs.surface,
        foregroundColor:
            isCurrentlyPlaying
                ? Colors.white
                : isActive
                ? cs.onPrimaryContainer
                : cs.onSurface,
        side: BorderSide(
          color:
              isCurrentlyPlaying
                  ? animation['color']
                  : cs.outline.withOpacity(0.3),
          width: isCurrentlyPlaying ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isCurrentlyPlaying ? 4 : 1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            animation['icon'],
            size: 20,
            color: isCurrentlyPlaying ? Colors.white : animation['color'],
          ),
          const SizedBox(height: 4),
          Text(
            animation['display']!,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleAnimation(String animationName) {
    setState(() {
      _animationStates[animationName] =
          !(_animationStates[animationName] ?? false);
    });

    _playAnimation(animationName);
  }

  void _playAnimation(String animationName) {
    setState(() {
      _currentAnimation = animationName;
    });

    // Reset the animation after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentAnimation = '';
        });
      }
    });

    // Show snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Playing animation: ${_getAnimationDisplayName(animationName)}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Playing animation: $animationName');
  }

  void _resetAllAnimations() {
    setState(() {
      _animationStates.updateAll((key, value) => false);
      _currentAnimation = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All animations reset'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Resetting all animations');
  }

  String _getAnimationDisplayName(String animationName) {
    final animation = animations.firstWhere(
      (anim) => anim['name'] == animationName,
      orElse: () => {'display': animationName},
    );
    return animation['display'];
  }
}
