import 'package:flutter/material.dart';
import '../services/eco_engine.dart';
import '../models/resource_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final engine = EcoEngine.instance;

  // Historical 6 months data for trend charts
  final List<Map<String, dynamic>> historicalData = [
    {'month': 'Jan', 'kwh': 210, 'co2': 230},
    {'month': 'Feb', 'kwh': 230, 'co2': 245},
    {'month': 'Mar', 'kwh': 280, 'co2': 290},
    {'month': 'Apr', 'kwh': 340, 'co2': 340},
    {'month': 'May', 'kwh': 380, 'co2': 375},
    {'month': 'Jun (Curr)', 'kwh': 360, 'co2': 355},
  ];

  @override
  Widget build(BuildContext context) {
    final input = engine.currentInput;
    final forecast = engine.forecastNextMonth(input);
    final impact = engine.calculateImpact(input);
    final persona = engine.getUserPersona(impact.ecoScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & ML Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forecast AI Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.white, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Next-Month ML Electricity Forecast',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Predicted Consumption',
                            style: TextStyle(color: Color(0xFFDDD6FE), fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${forecast.predictedKwh.toInt()} kWh',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              forecast.trend == 'increase' ? Icons.trending_up : Icons.trending_down,
                              color: forecast.trend == 'increase' ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${forecast.percentageChange}% ${forecast.trend}',
                              style: TextStyle(
                                color: forecast.trend == 'increase' ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated Next Month Bill: ₹${forecast.estimatedBill.toInt()}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Text(
                        'Linear Regression Model',
                        style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Persona Cluster
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFEDE9FE),
                      child: const Icon(Icons.bubble_chart, color: Color(0xFF6D28D9)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'K-Means Sustainability Cluster',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            persona,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4C1D95)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Historical Consumption Chart (Visual Bar Graph)
            const Text(
              '6-Month Consumption Trends (kWh)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: historicalData.map((data) {
                        double height = ((data['kwh'] as int) / 400.0) * 120.0;
                        return Column(
                          children: [
                            Text(
                              '${data['kwh']}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 32,
                              height: height,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    data['month'].toString().contains('Curr') ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                                    data['month'].toString().contains('Curr') ? const Color(0xFF059669) : const Color(0xFF4338CA),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['month'].toString().replaceAll(' (Curr)', '*'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'Summer months show expected seasonal air conditioning load spikes.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Methodology Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Color(0xFF374151), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'BCA Project Methodology & Pipeline',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Data Collection: 5 Core domains (Electricity, Water, Commute, Waste, Paper)\n'
                    '2. Feature Extraction: Household size, roof area, seasonal lag\n'
                    '3. ML Regression: Scikit-learn Ridge/Linear Regression for next-month load\n'
                    '4. Clustering: K-Means (k=3) for user behavioral segmentation\n'
                    '5. Decision Engine: Rule-based recommendation & Eco Points gamification',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF4B5563)),
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
}
