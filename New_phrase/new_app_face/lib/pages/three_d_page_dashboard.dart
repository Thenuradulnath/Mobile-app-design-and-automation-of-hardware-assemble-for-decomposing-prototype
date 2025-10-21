// lib/pages/three_d_page_dashboard.dart
import 'package:flutter/material.dart';

class ThreeDPageDashboard extends StatefulWidget {
  const ThreeDPageDashboard({Key? key}) : super(key: key);

  @override
  State<ThreeDPageDashboard> createState() => _ThreeDPageDashboardState();
}

class _ThreeDPageDashboardState extends State<ThreeDPageDashboard> {
  bool _isActivePhaseExpanded = false;
  bool _isCuringPhaseExpanded = false;

  // Placeholder values - will be replaced with backend data later
  final Map<String, Map<String, dynamic>> _activePhaseData = {
    'compartment1': {
      'temperature': 24.2,
      'moisture': 63,
      'ph': 7.1,
      'co2': 820,
    },
    'compartment2': {
      'temperature': 23.8,
      'moisture': 65,
      'ph': 7.3,
      'co2': 815,
    },
  };

  final Map<String, Map<String, dynamic>> _curingPhaseData = {
    'compartment3': {
      'temperature': 22.5,
      'moisture': 58,
      'ph': 7.0,
      'co2': 780,
    },
    'compartment4': {
      'temperature': 22.8,
      'moisture': 60,
      'ph': 6.9,
      'co2': 790,
    },
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Real Time Data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Active Phase Button
            _buildPhaseButton(
              context,
              title: 'Active Phase',
              isExpanded: _isActivePhaseExpanded,
              onTap: () {
                setState(() {
                  _isActivePhaseExpanded = !_isActivePhaseExpanded;
                  if (_isActivePhaseExpanded) {
                    _isCuringPhaseExpanded = false;
                  }
                });
              },
              color: Colors.orange,
            ),

            // Active Phase Expanded Content
            if (_isActivePhaseExpanded)
              _buildPhaseContent(
                context,
                compartment1Name: 'Compartment 1',
                compartment2Name: 'Compartment 2',
                compartment1Data: _activePhaseData['compartment1']!,
                compartment2Data: _activePhaseData['compartment2']!,
              ),

            const SizedBox(height: 8),

            // Curing Phase Button
            _buildPhaseButton(
              context,
              title: 'Curing Phase',
              isExpanded: _isCuringPhaseExpanded,
              onTap: () {
                setState(() {
                  _isCuringPhaseExpanded = !_isCuringPhaseExpanded;
                  if (_isCuringPhaseExpanded) {
                    _isActivePhaseExpanded = false;
                  }
                });
              },
              color: Colors.blue,
            ),

            // Curing Phase Expanded Content
            if (_isCuringPhaseExpanded)
              _buildPhaseContent(
                context,
                compartment1Name: 'Compartment 3',
                compartment2Name: 'Compartment 4',
                compartment1Data: _curingPhaseData['compartment3']!,
                compartment2Data: _curingPhaseData['compartment4']!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseButton(
    BuildContext context, {
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: color,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context, {
    required String compartment1Name,
    required String compartment2Name,
    required Map<String, dynamic> compartment1Data,
    required Map<String, dynamic> compartment2Data,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compartment 1
          Expanded(
            child: _buildCompartmentColumn(
              context,
              title: compartment1Name,
              data: compartment1Data,
            ),
          ),
          const SizedBox(width: 16),
          // Compartment 2
          Expanded(
            child: _buildCompartmentColumn(
              context,
              title: compartment2Name,
              data: compartment2Data,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompartmentColumn(
    BuildContext context, {
    required String title,
    required Map<String, dynamic> data,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const Divider(height: 12, thickness: 1),
        _buildDataItem(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: '${data['temperature'].toStringAsFixed(1)}°C',
        ),
        const SizedBox(height: 8),
        _buildDataItem(
          icon: Icons.water_drop,
          label: 'Moisture',
          value: '${data['moisture']}%',
        ),
        const SizedBox(height: 8),
        _buildDataItem(
          icon: Icons.science,
          label: 'pH',
          value: data['ph'].toStringAsFixed(1),
        ),
        const SizedBox(height: 8),
        _buildDataItem(
          icon: Icons.cloud,
          label: 'CO₂',
          value: '${data['co2']} ppm',
        ),
      ],
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const color = Color(0xFF16A34A);

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
