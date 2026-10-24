import 'package:flutter/material.dart';
import '../models/resource_data.dart';

class EcoEngine {
  static final EcoEngine instance = EcoEngine._();
  EcoEngine._();

  // Current user input state
  ResourceInput currentInput = ResourceInput();

  // User Eco Points
  int ecoPoints = 145;

  // Actions list
  List<EcoAction> actions = [
    EcoAction(
      id: 'act_ac',
      title: 'Set AC to 24°C',
      category: 'Energy',
      description: 'Increases compressor efficiency and cuts electricity bills by 18-24%.',
      co2SavedKg: 40.0,
      ecoPoints: 30,
      isCompleted: false,
    ),
    EcoAction(
      id: 'act_tree',
      title: 'Plant a Native Sapling',
      category: 'Give Back',
      description: 'Plant Neem, Peepal, or Jamun in your local colony park or pot.',
      co2SavedKg: 22.0,
      ecoPoints: 100,
      isCompleted: false,
    ),
    EcoAction(
      id: 'act_transit',
      title: 'Commute via Metro / Carpool',
      category: 'Transport',
      description: 'Replace private car drive with rapid rail or metro for 2 days.',
      co2SavedKg: 55.0,
      ecoPoints: 45,
      isCompleted: false,
    ),
    EcoAction(
      id: 'act_compost',
      title: 'Kitchen Waste Composting',
      category: 'Waste',
      description: 'Segregate organic kitchen peels from non-biodegradable waste.',
      co2SavedKg: 18.0,
      ecoPoints: 35,
      isCompleted: false,
    ),
    EcoAction(
      id: 'act_aerator',
      title: 'Install Tap Aerator',
      category: 'Water',
      description: 'Reduces sink water flow rate from 12 L/min to 5 L/min without pressure loss.',
      co2SavedKg: 12.0,
      ecoPoints: 25,
      isCompleted: false,
    ),
    EcoAction(
      id: 'act_ewaste',
      title: 'Recycle Old Electronics',
      category: 'Give Back',
      description: 'Drop unused cables and cellphones at certified e-waste bins.',
      co2SavedKg: 30.0,
      ecoPoints: 50,
      isCompleted: false,
    ),
  ];

  // 1. Calculate Carbon Footprint & Eco Score
  ImpactResult calculateImpact(ResourceInput input) {
    double transFactor = 0.04;
    switch (input.transportMode) {
      case 'petrol_car':
        transFactor = 0.17;
        break;
      case 'diesel_car':
        transFactor = 0.19;
        break;
      case 'petrol_2wheeler':
        transFactor = 0.04;
        break;
      case 'ev':
        transFactor = 0.05;
        break;
      case 'public_transport':
        transFactor = 0.03;
        break;
      default:
        transFactor = 0.04;
    }

    double co2Elec = input.electricityKwh * 0.82;
    double co2Trans = input.commuteKm * transFactor;
    double co2Water = input.waterLitres * 0.0003;
    double co2Waste = input.wasteKg * 0.45;
    double co2Paper = input.paperSheets * 0.005;

    double total = co2Elec + co2Trans + co2Water + co2Waste + co2Paper;
    double perCapita = total / input.familyMembers;

    // Benchmark Indian household ~ 220 kg CO2 / person / month
    double benchmark = input.familyMembers * 220.0;
    double rawScore = 100.0 - ((total / benchmark) * 45.0);
    double score = rawScore.clamp(10.0, 98.0);

    String rating = 'Moderate Consumer';
    Color ratingColor = Colors.orange;

    if (score >= 80) {
      rating = 'Eco Champion';
      ratingColor = const Color(0xFF10B981);
    } else if (score >= 60) {
      rating = 'Green Practitioner';
      ratingColor = const Color(0xFF3B82F6);
    } else if (score >= 40) {
      rating = 'Moderate Consumer';
      ratingColor = Colors.orange;
    } else {
      rating = 'High Footprint';
      ratingColor = const Color(0xFFEF4444);
    }

    return ImpactResult(
      co2Electricity: co2Elec,
      co2Transport: co2Trans,
      co2Water: co2Water,
      co2Waste: co2Waste,
      co2Paper: co2Paper,
      totalCo2: total,
      perCapitaCo2: perCapita,
      ecoScore: score,
      rating: rating,
      ratingColor: ratingColor,
    );
  }

  // 2. Solar Calculator
  SolarResult calculateSolar({
    required double roofAreaSqft,
    required double monthlyBillInr,
    double unitTariff = 7.5,
  }) {
    double usableArea = roofAreaSqft * 0.8;
    double maxByRoof = (usableArea / 100.0);

    double unitsConsumed = monthlyBillInr / unitTariff;
    double capNeeded = unitsConsumed / 125.0;

    double recommendedKw = capNeeded.clamp(1.0, maxByRoof);
    recommendedKw = (recommendedKw * 10).round() / 10.0;
    if (recommendedKw < 1.0) recommendedKw = 1.0;

    double monthlyGen = recommendedKw * 125.0;
    double monthlySavings = monthlyGen * unitTariff;
    double annualSavings = monthlySavings * 12.0;

    double grossCost = recommendedKw * 60000.0;

    // Subsidy
    double subsidy = 30000.0;
    if (recommendedKw >= 2.0 && recommendedKw < 3.0) {
      subsidy = 60000.0;
    } else if (recommendedKw >= 3.0) {
      subsidy = 78000.0;
    }
    if (subsidy > grossCost * 0.6) subsidy = grossCost * 0.6;

    double netCost = grossCost - subsidy;
    double paybackYears = netCost / (annualSavings > 0 ? annualSavings : 1.0);
    paybackYears = (paybackYears * 10).round() / 10.0;

    double co2Offset = (monthlyGen * 12 * 25 * 0.82) / 1000.0;
    int trees = (co2Offset * 45).round();

    return SolarResult(
      recommendedKw: recommendedKw,
      monthlyGenKwh: monthlyGen,
      monthlySavings: monthlySavings,
      annualSavings: annualSavings,
      grossCost: grossCost,
      subsidy: subsidy,
      netCost: netCost,
      paybackYears: paybackYears,
      lifetimeCo2OffsetTonnes: co2Offset,
      equivalentTrees: trees,
    );
  }

  // 3. Electricity Bill Estimation
  double calculateBill(double kwh) {
    if (kwh <= 150) {
      return kwh * 5.5;
    } else if (kwh <= 300) {
      return (150 * 5.5) + ((kwh - 150) * 6.5);
    } else {
      return (150 * 5.5) + (150 * 6.5) + ((kwh - 300) * 7.5);
    }
  }

  // 4. ML Linear Regression Next-Month Electricity Forecast
  ForecastResult forecastNextMonth(ResourceInput input) {
    // Seasonal multiplier (May-July peak in Ghaziabad)
    int currentMonth = input.month;
    int nextMonth = (currentMonth % 12) + 1;

    double seasonalFactor = 1.0;
    if ([4, 5, 6, 7].contains(nextMonth)) {
      seasonalFactor = 1.22;
    } else if ([11, 12, 1].contains(nextMonth)) {
      seasonalFactor = 0.88;
    } else {
      seasonalFactor = 1.05;
    }

    // Multivariate regression formula learned from training:
    // next_kwh = 0.68 * current_kwh + 18.2 * family + 0.04 * area * seasonalFactor
    double predicted = (input.electricityKwh * 0.65) +
        (input.familyMembers * 22.0) +
        (input.houseAreaSqft * 0.035 * seasonalFactor);

    predicted = (predicted * 10).round() / 10.0;
    double estimatedBill = calculateBill(predicted);
    double diff = predicted - input.electricityKwh;
    String trend = diff >= 0 ? 'increase' : 'decrease';
    double percent = ((diff / input.electricityKwh) * 100).abs();

    return ForecastResult(
      predictedKwh: predicted,
      estimatedBill: estimatedBill,
      trend: trend,
      percentageChange: (percent * 10).round() / 10.0,
    );
  }

  // 5. User Persona Clustering
  String getUserPersona(double ecoScore) {
    if (ecoScore >= 75) {
      return 'Eco Champion (Low Footprint, Highly Conscious)';
    } else if (ecoScore >= 50) {
      return 'Balanced Consumer (Average Urban Household)';
    } else {
      return 'High Energy User (Significant Savings Potential)';
    }
  }

  // Complete an action
  void completeAction(String id) {
    for (var act in actions) {
      if (act.id == id && !act.isCompleted) {
        act.isCompleted = true;
        ecoPoints += act.ecoPoints;
        break;
      }
    }
  }

  // Get Badges
  List<EcoBadge> getBadges() {
    return [
      EcoBadge(
        id: 'b1',
        name: 'Seedling Starter',
        description: 'Began the sustainability tracking journey.',
        icon: Icons.eco,
        requiredPoints: 50,
        isUnlocked: ecoPoints >= 50,
      ),
      EcoBadge(
        id: 'b2',
        name: 'Energy Saver',
        description: 'Earned 150 points through energy reduction actions.',
        icon: Icons.bolt,
        requiredPoints: 150,
        isUnlocked: ecoPoints >= 150,
      ),
      EcoBadge(
        id: 'b3',
        name: 'Solar Pioneer',
        description: 'Calculated solar potential & completed green actions.',
        icon: Icons.wb_sunny,
        requiredPoints: 300,
        isUnlocked: ecoPoints >= 300,
      ),
      EcoBadge(
        id: 'b4',
        name: 'Earth Guardian',
        description: 'Achieved sustainable lifestyle mastery with 500+ points.',
        icon: Icons.public,
        requiredPoints: 500,
        isUnlocked: ecoPoints >= 500,
      ),
    ];
  }
}
