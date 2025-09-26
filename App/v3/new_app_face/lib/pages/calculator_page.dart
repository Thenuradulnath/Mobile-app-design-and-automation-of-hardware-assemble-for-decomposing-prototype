import 'package:flutter/material.dart';
import '../app_store.dart';

class WasteType {
  final String name;
  final double ratio; // C:N (e.g., 30 == 30:1)
  final bool isCarbonRich; // true = brown, false = green
  const WasteType(this.name, this.ratio, this.isCarbonRich);
}

const double kTargetCN = 30.0;

// Demo-friendly library of organics
const List<WasteType> kWasteTypes = [
  // Greens (nitrogen-rich)
  WasteType('Vegetable Trimmings', 15, false),
  WasteType('Food Scraps', 15, false),
  WasteType('Coffee Grounds', 20, false),
  WasteType('Grass Clippings (fresh)', 17, false),
  WasteType('Spent Brewery Grains', 12, false),
  WasteType('Chicken Manure', 7, false),
  WasteType('Cow Manure', 20, false),

  // Browns (carbon-rich)
  WasteType('Dry Leaves', 60, true),
  WasteType('Straw', 80, true),
  WasteType('Paper', 150, true),
  WasteType('Cardboard', 350, true),
  WasteType('Sawdust', 400, true),
  WasteType('Wood Chips', 400, true),
  WasteType('Corn Stalks', 75, true),
];

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final List<({WasteType type, double kg})> _items = [];
  List<String> _recommendations = [];
  double? _lastRatio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text('Calculate C:N', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _openAddWaste,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Waste'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Text('Wastes', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No items yet. Tap “Add Waste”.'))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      final isBrown = it.type.isCarbonRich;
                      final gradient = LinearGradient(
                        colors: isBrown
                            ? const [Color(0xFF16A34A), Color(0xFF0E7A3B)]
                            : const [Color(0xFF059669), Color(0xFF047857)],
                      );
                      return Container(
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        child: ListTile(
                          title: Text(it.type.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            'Weight: ${_fmtKg(it.kg)} kg • ${it.type.ratio.toStringAsFixed(0)}:1',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              IconButton(
                                onPressed: () => _openAddWaste(editIndex: i),
                                icon: const Icon(Icons.edit, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _items.removeAt(i)),
                                icon: const Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_recommendations.isNotEmpty) ...[
            const Divider(height: 24),
            const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final line in _recommendations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(line, style: const TextStyle(fontSize: 16)),
              ),
          ],

          const SizedBox(height: 16),
          Center(child: FilledButton(onPressed: _calculate, child: const Text('Calculate'))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _calculate() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one waste item')),
      );
      return;
    }

    double c = 0, n = 0;
    for (final it in _items) {
      c += it.kg * it.type.ratio;
      n += it.kg;
    }
    final r = c / n;
    _lastRatio = r;

    List<WasteType> options;
    if (r < kTargetCN) {
      options = kWasteTypes.where((w) => w.isCarbonRich).toList()
        ..sort((a, b) => b.ratio.compareTo(a.ratio)); // higher first
    } else if (r > kTargetCN) {
      options = kWasteTypes.where((w) => !w.isCarbonRich).toList()
        ..sort((a, b) => a.ratio.compareTo(b.ratio)); // lower first
    } else {
      options = [];
    }

    final recos = <String>[];
    for (final w in options.take(3)) {
      final x = _kgToReachTarget(cTotal: c, nTotal: n, rAdd: w.ratio, target: kTargetCN);
      if (x != null) recos.add('${_roundNice(x)}kg of ${w.name}');
    }
    AppStore.lastCN = r;
    AppStore.lastRecommendations = recos;

    setState(() => _recommendations = recos);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Net Carbon to Nitrogen Ratio',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Current Ratio: ${r.toStringAsFixed(1)}:1'),
              const SizedBox(height: 10),
              const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (recos.isEmpty)
                const Text('You are already near 30:1')
              else
                for (final line in recos)
                  _GradientButton(label: line, onTap: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddWaste({int? editIndex}) {
    final editing = editIndex != null ? _items[editIndex] : null;
    final controller = TextEditingController(text: editing?.kg.toString() ?? '');
    WasteType selected = editing?.type ?? kWasteTypes.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(editIndex == null ? 'Add Waste' : 'Edit Waste',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<WasteType>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      for (final w in kWasteTypes)
                        DropdownMenuItem(
                          value: w,
                          child: Text('${w.name} (${w.ratio.toStringAsFixed(0)}:1)'),
                        )
                    ],
                    onChanged: (val) { if (val != null) selected = val; },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final kg = double.tryParse(controller.text.trim());
                      if (kg == null || kg <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid weight')),
                        );
                        return;
                      }
                      setState(() {
                        if (editIndex == null) {
                          _items.add((type: selected, kg: kg));
                        } else {
                          _items[editIndex] = (type: selected, kg: kg);
                        }
                        _recommendations = [];
                        _lastRatio = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(editIndex == null ? 'Add' : 'Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // math helpers
  double? _kgToReachTarget({
    required double cTotal,
    required double nTotal,
    required double rAdd,
    required double target,
  }) {
    final denom = (rAdd - target);
    final numer = (target * nTotal - cTotal);
    if (denom == 0) return null;
    final x = numer / denom;
    if (x.isNaN || x.isInfinite || x <= 0) return null;
    return x;
  }

  String _fmtKg(double x) =>
      x.toStringAsFixed(x.truncateToDouble() == x ? 0 : 1);

  String _roundNice(double x) {
    final r = (x * 10).round() / 10.0; // nearest 0.1
    return r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 1);
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF0E7A3B)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text('Apply',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}
