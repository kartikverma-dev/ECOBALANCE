import 'package:flutter/material.dart';
import '../services/eco_engine.dart';

class MoneyExpensesScreen extends StatefulWidget {
  const MoneyExpensesScreen({super.key});

  @override
  State<MoneyExpensesScreen> createState() => _MoneyExpensesScreenState();
}

class _MoneyExpensesScreenState extends State<MoneyExpensesScreen> {
  final engine = EcoEngine.instance;

  @override
  Widget build(BuildContext context) {
    final input = engine.currentInput;
    final elecBill = engine.calculateBill(input.electricityKwh);

    // Fuel cost estimation
    double fuelCost = 0.0;
    switch (input.transportMode) {
      case 'petrol_car':
        fuelCost = input.commuteKm * 7.5; // ~ ₹7.5/km
        break;
      case 'diesel_car':
        fuelCost = input.commuteKm * 8.0;
        break;
      case 'petrol_2wheeler':
        fuelCost = input.commuteKm * 2.2;
        break;
      case 'ev':
        fuelCost = input.commuteKm * 1.2;
        break;
      case 'public_transport':
        fuelCost = input.commuteKm * 1.5;
        break;
      default:
        fuelCost = input.commuteKm * 2.2;
    }

    // Water cost estimation (~₹45 per 1000L municipal/tanker average)
    double waterCost = (input.waterLitres / 1000.0) * 45.0;
    // Waste management fee / municipal charge
    double wasteFee = 150.0;

    double totalMonthlySpend = elecBill + fuelCost + waterCost + wasteFee;

    // Potential Savings
    double save10 = totalMonthlySpend * 0.10;
    double save20 = totalMonthlySpend * 0.20;
    double save30 = totalMonthlySpend * 0.30;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money & Resource Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Expenditure Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Resource Expenditure',
                    style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${totalMonthlySpend.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Electricity + Fuel + Water across ${input.familyMembers} family members',
                    style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expense Breakdown
            const Text(
              'Cost Breakdown by Utility',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildExpenseTile(
              title: 'Electricity Utility Bill',
              amount: elecBill,
              total: totalMonthlySpend,
              icon: Icons.electric_bolt,
              color: Colors.amber.shade800,
              detail: '${input.electricityKwh.toInt()} units (Slab-based tariff)',
            ),
            _buildExpenseTile(
              title: 'Transportation Fuel / Fares',
              amount: fuelCost,
              total: totalMonthlySpend,
              icon: Icons.local_gas_station,
              color: Colors.red.shade600,
              detail: '${input.commuteKm.toInt()} km commute via ${input.transportMode.replaceAll('_', ' ')}',
            ),
            _buildExpenseTile(
              title: 'Water Supply / Pumping',
              amount: waterCost,
              total: totalMonthlySpend,
              icon: Icons.water_drop,
              color: Colors.blue.shade600,
              detail: '${input.waterLitres.toInt()} Litres (~₹45/kL)',
            ),
            _buildExpenseTile(
              title: 'Municipal Solid Waste Charge',
              amount: wasteFee,
              total: totalMonthlySpend,
              icon: Icons.delete_outline,
              color: Colors.brown.shade400,
              detail: 'Fixed colony sanitation fee',
            ),

            const SizedBox(height: 24),

            // Potential Savings Simulator
            const Text(
              'Potential Financial Savings Simulator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'By adopting eco-actions, here is how much money you can put back in your wallet:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSavingsCard('10% Eco Shift', '₹${save10.toInt()}', '₹${(save10 * 12).toInt()} /yr', Colors.teal),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSavingsCard('20% Solar & Transit', '₹${save20.toInt()}', '₹${(save20 * 12).toInt()} /yr', Colors.green.shade700),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSavingsCard('30% Aggressive', '₹${save30.toInt()}', '₹${(save30 * 12).toInt()} /yr', Colors.indigo),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Financial Tip Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFFD97706), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tariff Slab Optimization Tip',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Units consumed above 300 kWh are charged at ₹7.50/unit instead of ₹5.50. Shaving just 40 kWh off peak consumption drops your tariff tier and saves ~₹300/month!',
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 11),
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

  Widget _buildExpenseTile({
    required String title,
    required double amount,
    required double total,
    required IconData icon,
    required Color color,
    required String detail,
  }) {
    double pct = total > 0 ? (amount / total) : 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(detail, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(
                  '₹${amount.toInt()}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(String title, String monthly, String yearly, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(monthly, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const Text('/ month', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(yearly, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
