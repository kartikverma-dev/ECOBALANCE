import 'package:flutter/material.dart';
import '../services/eco_engine.dart';
import '../models/resource_data.dart';

class SolarCalculatorScreen extends StatefulWidget {
  const SolarCalculatorScreen({super.key});

  @override
  State<SolarCalculatorScreen> createState() => _SolarCalculatorScreenState();
}

class _SolarCalculatorScreenState extends State<SolarCalculatorScreen> {
  final engine = EcoEngine.instance;

  double roofAreaSqft = 650.0;
  double monthlyBill = 2800.0;
  double tariff = 7.5;

  @override
  Widget build(BuildContext context) {
    final solar = engine.calculateSolar(
      roofAreaSqft: roofAreaSqft,
      monthlyBillInr: monthlyBill,
      unitTariff: tariff,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy & Solar Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solar Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Rooftop Solar Estimator',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Calculate system sizing, government subsidies (PM Surya Ghar), and financial ROI.',
                    style: TextStyle(color: Color(0xFFFFE0B2), fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sizing Inputs
            const Text(
              'Household Parameters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Roof Area Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.roofing, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Rooftop Area', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        Text(
                          '${roofAreaSqft.toInt()} sq.ft',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Slider(
                      value: roofAreaSqft,
                      min: 100,
                      max: 3000,
                      divisions: 29,
                      activeColor: Colors.orange,
                      onChanged: (val) {
                        setState(() {
                          roofAreaSqft = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Monthly Bill Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Current Monthly Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        Text(
                          '₹${monthlyBill.toInt()}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Slider(
                      value: monthlyBill,
                      min: 500,
                      max: 15000,
                      divisions: 58,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() {
                          monthlyBill = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            const Text(
              'Recommended Solar System',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Highlight Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildSolarStat(
                  title: 'System Size',
                  value: '${solar.recommendedKw} kWp',
                  icon: Icons.solar_power,
                  color: Colors.orange.shade800,
                ),
                _buildSolarStat(
                  title: 'Monthly Generation',
                  value: '${solar.monthlyGenKwh.toInt()} kWh',
                  icon: Icons.flash_on,
                  color: Colors.amber.shade700,
                ),
                _buildSolarStat(
                  title: 'Monthly Bill Savings',
                  value: '₹${solar.monthlySavings.toInt()}',
                  icon: Icons.savings,
                  color: Colors.green.shade700,
                ),
                _buildSolarStat(
                  title: 'Payback Period',
                  value: '${solar.paybackYears} Years',
                  icon: Icons.hourglass_bottom,
                  color: Colors.indigo,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Financial & Subsidy Breakdown Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Investment & Subsidy (PM Surya Ghar)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Divider(height: 20),
                    _buildCostRow('Estimated Gross Cost:', '₹${solar.grossCost.toInt()}'),
                    _buildCostRow('Central Government Subsidy:', '- ₹${solar.subsidy.toInt()}', isHighlight: true),
                    const Divider(height: 16),
                    _buildCostRow('Net Out-of-Pocket Investment:', '₹${solar.netCost.toInt()}', isBold: true),
                    _buildCostRow('Annual Electricity Savings:', '₹${solar.annualSavings.toInt()} / year', isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Environmental Impact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.park, color: Color(0xFF2E7D32), size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '25-Year Clean Energy Contribution',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Offsets ${solar.lifetimeCo2OffsetTonnes.toStringAsFixed(1)} Tonnes of CO2, equivalent to planting ${solar.equivalentTrees} trees!',
                          style: TextStyle(color: Colors.green.shade900, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isHighlight = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green.shade800 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? Colors.green.shade700 : (isBold ? Colors.black : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
