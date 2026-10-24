import 'package:flutter/material.dart';
import '../services/eco_engine.dart';
import '../models/resource_data.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final engine = EcoEngine.instance;

  @override
  Widget build(BuildContext context) {
    final impact = engine.calculateImpact(engine.currentInput);
    final bill = engine.calculateBill(engine.currentInput.electricityKwh);
    final persona = engine.getUserPersona(impact.ecoScore);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'EcoBalance',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 6),
                Text(
                  '${engine.ecoPoints} Pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Eva!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '“Measure your impact. Save your resources. Give back to the environment.”',
                    style: TextStyle(
                      color: Color(0xFFC8E6C9),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_pin, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          persona,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Eco Score Gauge Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Circular Gauge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: impact.ecoScore / 100.0,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(impact.ratingColor),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              impact.ecoScore.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: impact.ratingColor,
                              ),
                            ),
                            const Text(
                              '/ 100',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: impact.ratingColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                impact.rating,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: impact.ratingColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Total Footprint: ${impact.totalCo2.toStringAsFixed(1)} kg CO2e',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Per Capita: ${impact.perCapitaCo2.toStringAsFixed(1)} kg/member',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4 Quick Stat Cards
            const Text(
              'Monthly Resource Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  title: 'Electricity',
                  value: '${engine.currentInput.electricityKwh.toInt()} kWh',
                  icon: Icons.electric_bolt,
                  color: Colors.amber.shade700,
                  subtext: 'Bill: ₹${bill.toInt()}',
                ),
                _buildStatCard(
                  title: 'Water Usage',
                  value: '${engine.currentInput.waterLitres.toInt()} L',
                  icon: Icons.water_drop,
                  color: Colors.blue.shade600,
                  subtext: '~${(engine.currentInput.waterLitres / (engine.currentInput.familyMembers * 30)).toInt()} L/person/day',
                ),
                _buildStatCard(
                  title: 'Carbon Footprint',
                  value: '${impact.totalCo2.toInt()} kg',
                  icon: Icons.cloud_outlined,
                  color: Colors.red.shade400,
                  subtext: 'Grid & lifestyle CO2',
                ),
                _buildStatCard(
                  title: 'Eco Rewards',
                  value: '${engine.ecoPoints} Pts',
                  icon: Icons.military_tech,
                  color: Colors.green.shade700,
                  subtext: 'Level 2: Green Saver',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Modules Quick Access
            const Text(
              'Explore Project Modules',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildModuleCard(
              title: 'Module 1: My Impact',
              description: 'Log monthly electricity, water, commute & waste.',
              icon: Icons.calculate_outlined,
              color: Colors.teal,
              onTap: () => widget.onNavigate(1),
            ),
            _buildModuleCard(
              title: 'Module 2: Energy & Solar',
              description: 'Calculate solar rooftop capacity, subsidy & ROI.',
              icon: Icons.wb_sunny_outlined,
              color: Colors.orange.shade700,
              onTap: () => widget.onNavigate(2),
            ),
            _buildModuleCard(
              title: 'Module 3: Money & Savings',
              description: 'Analyze monthly utility spend and potential savings.',
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.indigo,
              onTap: () => widget.onNavigate(3),
            ),
            _buildModuleCard(
              title: 'Module 4: Give Back to Nature',
              description: 'Personalized green challenges & earn Eco Points.',
              icon: Icons.volunteer_activism_outlined,
              color: Colors.green.shade700,
              onTap: () => widget.onNavigate(4),
            ),
            _buildModuleCard(
              title: 'Module 5: Analytics & Forecast',
              description: 'Linear Regression model next-month electricity forecast.',
              icon: Icons.auto_graph,
              color: Colors.purple,
              onTap: () => widget.onNavigate(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
