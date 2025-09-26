import 'package:flutter/material.dart';
import '../app_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget summaryTile({
      required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
      List<Color>? gradient,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient != null
                ? LinearGradient(colors: gradient)
                : null,
            color: gradient == null ? cs.surface : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      );
    }

    // Build dynamic subtitles from AppStore
    final sensorsSub = AppStore.sensorsTotal == 0
        ? 'No sensors yet'
        : '${AppStore.sensorsOnline}/${AppStore.sensorsTotal} online · '
          '${AppStore.sensorsAlerts} alert${AppStore.sensorsAlerts == 1 ? '' : 's'}';

    final calcSub = AppStore.lastCN == null
        ? 'Not calculated yet'
        : 'Last C:N ≈ ${AppStore.lastCN!.toStringAsFixed(1)}:1';

    final threeDSub = AppStore.modelLoaded ? 'Model ready' : 'Loading…';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Image.asset('assets/logo.png', height: 28),
              const Spacer(),
              const CircleAvatar(child: Text('TH')),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            child: ListTile(
              title: const Text('Hey, thenurad'),
              subtitle: const Text('Welcome back'),
              trailing: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add new Device'),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 10),

          // Distinct grid look on Home
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // one-column tall tiles for phone; easy to read
              mainAxisSpacing: 12,
              childAspectRatio: 3.8,
            ),
            children: [
              // Sensors tile (green gradient)
              summaryTile(
                title: 'Sensors',
                subtitle: sensorsSub,
                icon: Icons.sensors,
                onTap: () => AppNav.index.value = 1,
                gradient: const [Color(0xFF16A34A), Color(0xFF0E7A3B)],
              ),
              // 3D tile (teal gradient)
              summaryTile(
                title: '3D',
                subtitle: threeDSub,
                icon: Icons.threed_rotation,
                onTap: () => AppNav.index.value = 3,
                gradient: const [Color(0xFF10B981), Color(0xFF0EA5A5)],
              ),
              // Calculation tile (blue/green)
              summaryTile(
                title: 'Calculation',
                subtitle: calcSub,
                icon: Icons.calculate_outlined,
                onTap: () => AppNav.index.value = 4,
                gradient: const [Color(0xFF059669), Color(0xFF047857)],
              ),
              // Routines tile (placeholder)
              summaryTile(
                title: 'Routines',
                subtitle: 'Tap to manage (coming soon)',
                icon: Icons.play_circle_outline,
                onTap: () => AppNav.index.value = 2,
                gradient: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
