import 'package:flutter/material.dart';

class ResourceInput {
  double electricityKwh;
  double waterLitres;
  double commuteKm;
  String transportMode; // petrol_car, diesel_car, petrol_2wheeler, ev, public_transport
  double wasteKg;
  double paperSheets;
  int familyMembers;
  int month; // 1 to 12
  double houseAreaSqft;

  ResourceInput({
    this.electricityKwh = 320.0,
    this.waterLitres = 12000.0,
    this.commuteKm = 350.0,
    this.transportMode = 'petrol_2wheeler',
    this.wasteKg = 24.0,
    this.paperSheets = 60.0,
    this.familyMembers = 4,
    this.month = 5,
    this.houseAreaSqft = 1200.0,
  });
}

class ImpactResult {
  final double co2Electricity;
  final double co2Transport;
  final double co2Water;
  final double co2Waste;
  final double co2Paper;
  final double totalCo2;
  final double perCapitaCo2;
  final double ecoScore;
  final String rating;
  final Color ratingColor;

  ImpactResult({
    required this.co2Electricity,
    required this.co2Transport,
    required this.co2Water,
    required this.co2Waste,
    required this.co2Paper,
    required this.totalCo2,
    required this.perCapitaCo2,
    required this.ecoScore,
    required this.rating,
    required this.ratingColor,
  });
}

class SolarResult {
  final double recommendedKw;
  final double monthlyGenKwh;
  final double monthlySavings;
  final double annualSavings;
  final double grossCost;
  final double subsidy;
  final double netCost;
  final double paybackYears;
  final double lifetimeCo2OffsetTonnes;
  final int equivalentTrees;

  SolarResult({
    required this.recommendedKw,
    required this.monthlyGenKwh,
    required this.monthlySavings,
    required this.annualSavings,
    required this.grossCost,
    required this.subsidy,
    required this.netCost,
    required this.paybackYears,
    required this.lifetimeCo2OffsetTonnes,
    required this.equivalentTrees,
  });
}

class ForecastResult {
  final double predictedKwh;
  final double estimatedBill;
  final String trend; // 'increase' or 'decrease'
  final double percentageChange;

  ForecastResult({
    required this.predictedKwh,
    required this.estimatedBill,
    required this.trend,
    required this.percentageChange,
  });
}

class EcoAction {
  final String id;
  final String title;
  final String category;
  final String description;
  final double co2SavedKg;
  final int ecoPoints;
  bool isCompleted;

  EcoAction({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.co2SavedKg,
    required this.ecoPoints,
    this.isCompleted = false,
  });
}

class EcoBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int requiredPoints;
  final bool isUnlocked;

  EcoBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredPoints,
    required this.isUnlocked,
  });
}
