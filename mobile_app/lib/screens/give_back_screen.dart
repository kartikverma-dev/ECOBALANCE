import 'package:flutter/material.dart';
import '../services/eco_engine.dart';
import '../models/resource_data.dart';

class GiveBackScreen extends StatefulWidget {
  const GiveBackScreen({super.key});

  @override
  State<GiveBackScreen> createState() => _GiveBackScreenState();
}

class _GiveBackScreenState extends State<GiveBackScreen> {
  final engine = EcoEngine.instance;

  @override
  Widget build(BuildContext context) {
    final badges = engine.getBadges();
    final actions = engine.actions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Back to Nature', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eco Points & Level Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Eco Points Balance',
                          style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${engine.ecoPoints} Points',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tier: Active Green Steward 🌱',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personalized Recommendations Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tailored Action Engine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Data-Driven',
                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Actions personalized based on your highest monthly emission sources:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Action Checklist
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: action.isCompleted ? Colors.green.shade300 : Colors.grey.shade200,
                      width: action.isCompleted ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            action.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: action.isCompleted ? const Color(0xFF10B981) : Colors.grey,
                            size: 26,
                          ),
                          onPressed: () {
                            setState(() {
                              engine.completeAction(action.id);
                            });
                            if (!action.isCompleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Completed "${action.title}"! Earned +${action.ecoPoints} Eco Points! 🎉'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      action.category,
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '+${action.ecoPoints} Pts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                action.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: action.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                action.description,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.eco, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Saves ${action.co2SavedKg.toInt()} kg CO2/month',
                                    style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Achievement Badges Gallery
            const Text(
              'Sustainability Badges & Achievements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final b = badges[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: b.isUnlocked ? const Color(0xFFF0FDF4) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: b.isUnlocked ? const Color(0xFF86EFAC) : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        b.icon,
                        size: 32,
                        color: b.isUnlocked ? const Color(0xFF16A34A) : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: b.isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b.isUnlocked ? 'Unlocked' : 'Need ${b.requiredPoints} pts',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: b.isUnlocked ? const Color(0xFF16A34A) : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
