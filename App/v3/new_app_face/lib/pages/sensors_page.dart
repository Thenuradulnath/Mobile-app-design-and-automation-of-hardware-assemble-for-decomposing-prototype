// lib/pages/sensors_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../app_store.dart';

enum SensorType { numeric, toggle }

class Sensor {
  final String id;
  final String name;
  final IconData icon;
  final SensorType type;

  // status
  bool online;
  bool live;

  // numeric fields
  double value;
  final String unit;
  final double min;
  final double max;
  double lo; // low alert
  double hi; // high alert

  // toggle value (only used when type == toggle)
  bool boolValue;

  Sensor.numeric({
    required this.id,
    required this.name,
    required this.icon,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.lo,
    required this.hi,
    this.online = true,
    this.live = false,
  })  : type = SensorType.numeric,
        boolValue = true;

  Sensor.toggle({
    required this.id,
    required this.name,
    required this.icon,
    required this.boolValue,
    this.online = true,
    this.live = false,
  })  : type = SensorType.toggle,
        value = 0,
        unit = '',
        min = 0,
        max = 1,
        lo = 0,
        hi = 1;

  bool get inAlert => type == SensorType.numeric && (value < lo || value > hi);
}

class SensorsPage extends StatefulWidget {
  const SensorsPage({Key? key}) : super(key: key);

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  final _rng = Random();
  final Map<String, Timer> _timers = {};

  late List<Sensor> sensors = [
    Sensor.numeric(
      id: 'temp',
      name: 'Temperature',
      icon: Icons.thermostat,
      value: 24.2,
      unit: '°C',
      min: 0,
      max: 80,
      lo: 5,
      hi: 50,
    ),
    Sensor.numeric(
      id: 'hum',
      name: 'Humidity',
      icon: Icons.water_drop,
      value: 63,
      unit: '%',
      min: 0,
      max: 100,
      lo: 20,
      hi: 90,
    ),
    Sensor.numeric(
      id: 'ph',
      name: 'pH',
      icon: Icons.science,
      value: 7.1,
      unit: '',
      min: 0,
      max: 14,
      lo: 5.5,
      hi: 8.5,
    ),
    Sensor.numeric(
      id: 'co2',
      name: 'CO₂',
      icon: Icons.cloud,
      value: 820,
      unit: 'ppm',
      min: 350,
      max: 5000,
      lo: 400,
      hi: 2000,
    ),
    Sensor.numeric(
      id: 'rpm',
      name: 'Drum Speed',
      icon: Icons.rotate_right,
      value: 12,
      unit: 'rpm',
      min: 0,
      max: 60,
      lo: 2,
      hi: 40,
    ),
    Sensor.toggle(
      id: 'lid',
      name: 'Lid Closed',
      icon: Icons.lock,
      boolValue: true,
    ),
  ];

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  void _toggleLive(Sensor s) {
    setState(() => s.live = !s.live);
    if (s.live) {
      _timers[s.id]?.cancel();
      _timers[s.id] = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (!s.online || s.type != SensorType.numeric) return;
        final band = (s.max - s.min) * 0.02; // 2% jitter
        final delta = (_rng.nextDouble() * 2 - 1) * band;
        setState(() {
          s.value = (s.value + delta).clamp(s.min, s.max);
        });
      });
    } else {
      _timers[s.id]?.cancel();
      _timers.remove(s.id);
    }
  }
  
  void _pushSummary() {
  final total = sensors.length;
  final online = sensors.where((s) => s.online).length;
  final alerts = sensors.where((s) =>
      s.online && s.type == SensorType.numeric && s.inAlert).length;
  AppStore.setSensorsSummary(total: total, online: online, alerts: alerts);
}


  void _toggleOnline(Sensor s) {
    setState(() => s.online = !s.online);
    if (!s.online) {
      // pause live updates when offline
      _timers[s.id]?.cancel();
      _timers.remove(s.id);
      s.live = false;
    }
  }

  void _openAdjust(Sensor s) {
    if (s.type == SensorType.numeric) {
      final val = ValueNotifier<double>(s.value);
      final lo = ValueNotifier<double>(s.lo);
      final hi = ValueNotifier<double>(s.hi);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adjust ${s.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                ValueListenableBuilder<double>(
                  valueListenable: val,
                  builder: (_, v, __) => Text('Value: ${v.toStringAsFixed(1)} ${s.unit}'),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: val,
                  builder: (_, v, __) => Slider(
                    value: v,
                    min: s.min,
                    max: s.max,
                    onChanged: s.online ? (nv) => val.value = nv : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Alerts'),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<double>(
                        valueListenable: lo,
                        builder: (_, v, __) => TextFormField(
                          initialValue: v.toStringAsFixed(1),
                          decoration: const InputDecoration(labelText: 'Low'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (t) {
                            final d = double.tryParse(t);
                            if (d != null) lo.value = d;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<double>(
                        valueListenable: hi,
                        builder: (_, v, __) => TextFormField(
                          initialValue: v.toStringAsFixed(1),
                          decoration: const InputDecoration(labelText: 'High'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (t) {
                            final d = double.tryParse(t);
                            if (d != null) hi.value = d;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            s.value = val.value.clamp(s.min, s.max);
                            s.lo = min(lo.value, hi.value);
                            s.hi = max(lo.value, hi.value);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    } else {
      // toggle sensor
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Set ${s.name}'),
          content: SwitchListTile(
            value: s.boolValue,
            onChanged: s.online
                ? (v) {
                    setState(() => s.boolValue = v);
                    Navigator.pop(context);
                  }
                : null,
            title: Text(s.boolValue ? 'ON' : 'OFF'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header (visually distinct from other pages)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text('Sensors', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const _LegendDot(color: Color(0xFF16A34A), label: 'OK'),
                  const SizedBox(width: 10),
                  const _LegendDot(color: Color(0xFFE11D48), label: 'Alert'),
                  const SizedBox(width: 10),
                  const _LegendDot(color: Colors.grey, label: 'Offline'),
                ],
              ),
            ),
          ),
        ),

        // Grid of sensor cards
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: sensors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final s = sensors[i];
              return _SensorCard(
                sensor: s,
                onToggleLive: () => _toggleLive(s),
                onToggleOnline: () => _toggleOnline(s),
                onAdjust: () => _openAdjust(s),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final Sensor sensor;
  final VoidCallback onToggleLive;
  final VoidCallback onToggleOnline;
  final VoidCallback onAdjust;

  const _SensorCard({
    required this.sensor,
    required this.onToggleLive,
    required this.onToggleOnline,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = !sensor.online
        ? Colors.grey
        : sensor.inAlert
            ? const Color(0xFFE11D48) // red
            : const Color(0xFF16A34A); // green

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title row
            Row(
              children: [
                Icon(sensor.icon, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(sensor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(.35)),
                  ),
                  child: Text(
                    !sensor.online
                        ? 'OFFLINE'
                        : sensor.inAlert
                            ? 'ALERT'
                            : sensor.live
                                ? 'LIVE'
                                : 'OK',
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // big value
            Center(
              child: sensor.type == SensorType.numeric
                  ? RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 26),
                        children: [
                          TextSpan(
                            text: sensor.value.toStringAsFixed(
                                sensor.value.truncateToDouble() == sensor.value ? 0 : 1),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' ${sensor.unit}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Text(
                      sensor.boolValue ? 'ON' : 'OFF',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
            ),
            const Spacer(),

            // controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ChipSwitch(
                  label: 'Live',
                  value: sensor.live,
                  onTap: sensor.online ? onToggleLive : null,
                ),
                _ChipSwitch(
                  label: sensor.online ? 'Online' : 'Offline',
                  value: sensor.online,
                  onTap: onToggleOnline,
                ),
                IconButton(
                  onPressed: sensor.online ? onAdjust : null,
                  icon: const Icon(Icons.tune),
                  tooltip: 'Adjust',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback? onTap;

  const _ChipSwitch({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF)),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? const Color(0xFF166534) : const Color(0xFF374151),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
