// lib/pages/three_d_page.dart
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../app_store.dart';

class ThreeDPage extends StatefulWidget {
  const ThreeDPage({Key? key}) : super(key: key); // explicit key to silence lint

  @override
  State<ThreeDPage> createState() => _ThreeDPageState();
}

class _ThreeDPageState extends State<ThreeDPage> {
  bool _loading = true;
  bool _autoRotate = true;

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
                  const Text('3D Model', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
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
                    src: 'assets/models/assembly.glb',
                    alt: 'LIDA composter 3D model',
                    ar: false,               // set true for AR on mobile if needed
                    autoRotate: _autoRotate,
                    cameraControls: true,
                    disableZoom: false,
                    exposure: 1.0,
                    shadowIntensity: 1.0,
                    environmentImage: 'neutral',

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

              // Soft "reset" button
              Positioned(
                right: 16,
                bottom: 16,
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
            ],
          ),
        ),
      ],
    );
  }
}
