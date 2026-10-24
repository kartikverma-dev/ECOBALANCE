import 'package:flutter/material.dart';
import '../services/eco_engine.dart';
import '../models/resource_data.dart';

class MyImpactScreen extends StatefulWidget {
  const MyImpactScreen({super.key});

  @override
  State<MyImpactScreen> createState() => _MyImpactScreenState();
}

class _MyImpactScreenState extends State<MyImpactScreen> {
  final engine = EcoEngine.instance;

  late double electricity;
  late double water;
  late double commute;
  late String transportMode;
  late double waste;
  late double paper;
  late int familyMembers;

  @override
  void initState() {
    super.initState();
    electricity = engine.currentInput.electricityKwh;
    water = engine.currentInput.waterLitres;
    commute = engine.currentInput.commuteKm;
    transportMode = engine.currentInput.transportMode;
    waste = engine.currentInput.wasteKg;
    paper = engine.currentInput.paperSheets;
    familyMembers = engine.currentInput.familyMembers;
  }

  void _syncInputs() {
    setState(() {
      engine.currentInput.electricityKwh = electricity;
      engine.currentInput.waterLitres = water;
      engine.currentInput.commuteKm = commute;
      engine.currentInput.transportMode = transportMode;
      engine.currentInput.wasteKg = waste;
      engine.currentInput.paperSheets = paper;
      engine.currentInput.familyMembers = familyMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final impact = engine.calculateImpact(engine.currentInput);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Impact Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Result Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: impact.ratingColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: impact.ratingColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: impact.ratingColor,
                    child: Text(
                      impact.ecoScore.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          impact.rating,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: impact.ratingColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Monthly CO2: ${impact.totalCo2.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          'Per Person: ${impact.perCapitaCo2.toStringAsFixed(1)} kg CO2e / month',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emission Breakdown Bars
            const Text(
              'CO2 Emission Breakdown',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBreakdownRow('Electricity (0.82 kg/kWh)', impact.co2Electricity, impact.totalCo2, Colors.amber.shade700),
            _buildBreakdownRow('Transport / Commute', impact.co2Transport, impact.totalCo2, Colors.blue.shade600),
            _buildBreakdownRow('Water Usage', impact.co2Water, impact.totalCo2, Colors.cyan.shade600),
            _buildBreakdownRow('Solid Waste', impact.co2Waste, impact.totalCo2, Colors.brown.shade400),
            _buildBreakdownRow('Paper Consumption', impact.co2Paper, impact.totalCo2, Colors.purple.shade400),

            const Divider(height: 32),

            const Text(
              'Update Your Lifestyle Inputs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Family Size
            _buildSliderCard(
              title: 'Family Members',
              value: familyMembers.toDouble(),
              unit: 'People',
              min: 1,
              max: 8,
              divisions: 7,
              icon: Icons.group,
              color: Colors.indigo,
              onChanged: (val) {
                familyMembers = val.toInt();
                _syncInputs();
              },
            ),

            // Electricity Slider
            _buildSliderCard(
              title: 'Monthly Electricity Consumption',
              value: electricity,
              unit: 'kWh / Units',
              min: 50,
              max: 1000,
              divisions: 95,
              icon: Icons.electric_bolt,
              color: Colors.amber.shade700,
              onChanged: (val) {
                electricity = val;
                _syncInputs();
              },
            ),

            // Water Slider
            _buildSliderCard(
              title: 'Monthly Water Consumption',
              value: water,
              unit: 'Litres',
              min: 1000,
              max: 30000,
              divisions: 58,
              icon: Icons.water_drop,
              color: Colors.blue.shade600,
              onChanged: (val) {
                water = val;
                _syncInputs();
              },
            ),

            // Commute Distance
            _buildSliderCard(
              title: 'Monthly Commute Distance',
              value: commute,
              unit: 'km',
              min: 0,
              max: 1500,
              divisions: 60,
              icon: Icons.directions_car,
              color: Colors.teal,
              onChanged: (val) {
                commute = val;
                _syncInputs();
              },
            ),

            // Transport Mode Selector
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Transport Mode',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: transportMode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'petrol_2wheeler', child: Text('Two-Wheeler (Petrol, ~0.04 kg/km)')),
                        DropdownMenuItem(value: 'petrol_car', child: Text('Car (Petrol, ~0.17 kg/km)')),
                        DropdownMenuItem(value: 'diesel_car', child: Text('Car (Diesel, ~0.19 kg/km)')),
                        DropdownMenuItem(value: 'ev', child: Text('Electric Vehicle (EV, ~0.05 kg/km)')),
                        DropdownMenuItem(value: 'public_transport', child: Text('Metro / Bus (~0.03 kg/km)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          transportMode = val;
                          _syncInputs();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Waste Slider
            _buildSliderCard(
              title: 'Monthly Solid Waste',
              value: waste,
              unit: 'kg',
              min: 5,
              max: 100,
              divisions: 95,
              icon: Icons.delete_outline,
              color: Colors.brown.shade400,
              onChanged: (val) {
                waste = val;
                _syncInputs();
              },
            ),

            // Paper Slider
            _buildSliderCard(
              title: 'Monthly Paper Usage',
              value: paper,
              unit: 'Sheets',
              min: 0,
              max: 500,
              divisions: 50,
              icon: Icons.description_outlined,
              color: Colors.purple.shade400,
              onChanged: (val) {
                paper = val;
                _syncInputs();
              },
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lifestyle inputs saved & Eco Impact Score re-calculated!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Save Lifestyle Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double co2, double total, Color color) {
    double pct = total > 0 ? (co2 / total) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text(
                '${co2.toStringAsFixed(1)} kg (${(pct * 100).toStringAsFixed(0)}%)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required String unit,
    required double min,
    required double max,
    required int divisions,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Text(
                  '${value.toInt()} $unit',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
