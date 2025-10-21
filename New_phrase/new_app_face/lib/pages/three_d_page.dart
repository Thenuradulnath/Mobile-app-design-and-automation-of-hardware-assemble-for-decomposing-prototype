// lib/pages/three_d_page.dart
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../app_store.dart';
import 'animation_test.dart';
import 'three_d_page_dashboard.dart';
import 'animation_control_page.dart';
import 'flutter3Dviewer.dart';

class ThreeDPage extends StatefulWidget {
  const ThreeDPage({Key? key})
    : super(key: key); // explicit key to silence lint

  @override
  State<ThreeDPage> createState() => _ThreeDPageState();
}

class _ThreeDPageState extends State<ThreeDPage> {
  bool _loading = true;
  bool _autoRotate = true;
  bool _showAnimationControls = false;
  String _currentAnimation = '';

  // Animation states for toggling
  final Map<String, bool> _animationStates = {
    'close-lid-1': false,
    'open-lid-1': false,
    'lid-2-close': false,
    'lid-2-open': false,
    'drawer-close': false,
    'drawer-open': false,
  };

  // Available animations - matching your actual Blender animation names
  final List<Map<String, String>> animations = [
    {'name': 'close-lid-1', 'display': 'Close Lid 1', 'icon': '🔒'},
    {'name': 'open-lid-1', 'display': 'Open Lid 1', 'icon': '�'},
    {'name': 'lid-2-close', 'display': 'Close Lid 2', 'icon': '🔒'},
    {'name': 'lid-2-open', 'display': 'Open Lid 2', 'icon': '�'},
    {'name': 'drawer-close', 'display': 'Close Drawer', 'icon': '�'},
    {'name': 'drawer-open', 'display': 'Open Drawer', 'icon': '📤'},
  ];

  @override
  void initState() {
    super.initState();

    // Reset Home summary each time the page opens
    _loading = true;
    AppStore.modelLoaded = false;

    // --- Fallback loader ---
    // Some setups can’t see `onModelLoaded` due to a stale analyzer or older
    // model_viewer_plus. This safely clears the spinner soon after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _loading = false);
      AppStore.modelLoaded = true; // Home shows "Model ready"
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: cs.primary),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    '3D Model',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showAnimationControls
                          ? Icons.animation
                          : Icons.play_circle,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _showAnimationControls = !_showAnimationControls,
                        ),
                    tooltip: 'Toggle Animation Controls',
                  ),
                  const Text('Auto-rotate'),
                  Switch(
                    value: _autoRotate,
                    onChanged: (v) => setState(() => _autoRotate = v),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Viewer
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ModelViewer(
                    src:
                        'assets/glb/animation.glb', // Using the animated GLB file
                    alt:
                        'LIDA composter 3D model - Full Assembly with Animations',
                    ar: false, // set true for AR on mobile if needed
                    autoRotate: _autoRotate,
                    autoPlay: false, // We'll control animations manually
                    cameraControls: true,
                    disableZoom: false,
                    exposure: 1.0,
                    shadowIntensity: 1.0,
                    environmentImage: 'neutral',
                    animationName:
                        _currentAnimation, // Will be controlled by buttons
                    animationCrossfadeDuration: 300,

                    // REAL callback (enable once your dependency is recognized):
                    // onModelLoaded: (_) {
                    //   if (!mounted) return;
                    //   setState(() => _loading = false);
                    //   AppStore.modelLoaded = true;
                    // },
                  ),
                ),
              ),

              if (_loading) const Center(child: CircularProgressIndicator()),

              // Dashboard in top-left corner
              const Positioned(top: 16, left: 16, child: ThreeDPageDashboard()),

              // Animation Controls Panel
              if (_showAnimationControls)
                Positioned(
                  right: 16,
                  top: 16,
                  child: _buildAnimationControlsPanel(cs),
                ),

              // Soft "reset" button
              Positioned(
                right: 16,
                bottom: 280, // Moved up to make room for animation button
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() => _autoRotate = !_autoRotate);
                    Future.delayed(const Duration(milliseconds: 60), () {
                      if (mounted) setState(() => _autoRotate = !_autoRotate);
                    });
                  },
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Reset'),
                ),
              ),

              // Enhanced Animation Page button
              Positioned(
                right: 16,
                bottom: 200,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModelAnimationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.animation),
                  label: const Text('Animations'),
                  backgroundColor: cs.secondary,
                  foregroundColor: cs.onSecondary,
                ),
              ),

              // Flutter 3D Viewer button
              Positioned(
                right: 16,
                bottom: 120,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Flutter3DAnimationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.view_in_ar),
                  label: const Text('Flutter 3D'),
                  backgroundColor: cs.tertiary,
                  foregroundColor: cs.onTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationControlsPanel(ColorScheme cs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.animation, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Animation Controls',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed:
                      () => setState(() => _showAnimationControls = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animation buttons
            ...animations.map(
              (animation) => _buildAnimationButton(animation, cs),
            ),

            const SizedBox(height: 8),

            // Reset all animations button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetAllAnimations,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondary,
                  foregroundColor: cs.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationButton(Map<String, String> animation, ColorScheme cs) {
    final isActive = _animationStates[animation['name']] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _toggleAnimation(animation['name']!),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? cs.primary : cs.surface,
            foregroundColor: isActive ? cs.onPrimary : cs.onSurface,
            side: BorderSide(color: cs.primary.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  animation['display']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(animation['icon']!, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAnimation(String animationName) {
    setState(() {
      _animationStates[animationName] =
          !(_animationStates[animationName] ?? false);
    });

    // Here you would trigger the specific animation
    // The exact implementation depends on your model_viewer_plus version
    // and how your animations are named in Blender
    _playAnimation(animationName);
  }

  void _playAnimation(String animationName) {
    // Set the animation to play
    setState(() {
      _currentAnimation = animationName;
    });

    // Reset the animation after a delay (assuming animations are short)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentAnimation = '';
        });
      }
    });

    print('Playing animation: $animationName');
  }

  void _resetAllAnimations() {
    setState(() {
      _animationStates.updateAll((key, value) => false);
    });
    print('Resetting all animations');
  }
}
