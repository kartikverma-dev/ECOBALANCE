"""
EcoBalance - Flask REST API
Author: Eva Tomar (Roll No: 240935106093)
Institute of Management Studies Ghaziabad
BCA Final Year Project
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from ml_pipeline import EcoBalanceML

app = Flask(__name__)
CORS(app)

# Initialize ML Pipeline
ml = EcoBalanceML()
models_dir = os.path.join(os.path.dirname(__file__), 'models')
if os.path.exists(models_dir):
    try:
        ml.load(models_dir)
        print("Trained ML models loaded successfully.")
    except Exception as e:
        print(f"Notice: Could not load trained models, will use algorithmic fallback: {e}")

# Standard GHG emission factors
EMISSION_FACTORS = {
    'electricity_kwh': 0.82,     # kg CO2 / kWh (India CEA Grid Factor)
    'water_litre': 0.0003,       # kg CO2 / Litre
    'waste_kg': 0.45,            # kg CO2 / kg MSW
    'paper_sheet': 0.005,        # kg CO2 / A4 sheet
    'transport_km': {
        'petrol_car': 0.17,
        'diesel_car': 0.19,
        'petrol_2wheeler': 0.04,
        'ev': 0.05,
        'public_transport': 0.03,
        'bicycle_walking': 0.0
    }
}

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'project': 'EcoBalance',
        'author': 'Eva Tomar (240935106093)',
        'institution': 'IMS Ghaziabad'
    })

@app.route('/api/impact/calculate', methods=['POST'])
def calculate_impact():
    """
    Module 1: My Impact - Carbon Footprint & Eco Impact Score
    """
    data = request.get_json() or {}
    
    electricity_kwh = float(data.get('electricity_kwh', 0.0))
    water_litres = float(data.get('water_litres', 0.0))
    commute_km = float(data.get('commute_km', 0.0))
    transport_mode = data.get('transport_mode', 'petrol_2wheeler')
    waste_kg = float(data.get('waste_kg', 0.0))
    paper_sheets = float(data.get('paper_sheets', 0.0))
    family_members = max(1, int(data.get('family_members', 4)))
    
    trans_factor = EMISSION_FACTORS['transport_km'].get(transport_mode, 0.04)
    
    co2_electricity = round(electricity_kwh * EMISSION_FACTORS['electricity_kwh'], 2)
    co2_transport = round(commute_km * trans_factor, 2)
    co2_water = round(water_litres * EMISSION_FACTORS['water_litre'], 2)
    co2_waste = round(waste_kg * EMISSION_FACTORS['waste_kg'], 2)
    co2_paper = round(paper_sheets * EMISSION_FACTORS['paper_sheet'], 2)
    
    total_co2 = round(co2_electricity + co2_transport + co2_water + co2_waste + co2_paper, 2)
    per_capita_co2 = round(total_co2 / family_members, 2)
    
    # Eco Impact Score (0 to 100)
    # Benchmark Indian household ~ 220 kg CO2 / person / month
    household_benchmark = family_members * 220.0
    raw_score = 100.0 - ((total_co2 / household_benchmark) * 45.0)
    eco_impact_score = round(max(5.0, min(99.0, raw_score)), 1)
    
    # Rating label
    if eco_impact_score >= 80:
        rating = "Eco Champion"
        rating_color = "#10B981"
    elif eco_impact_score >= 60:
        rating = "Good Steward"
        rating_color = "#3B82F6"
    elif eco_impact_score >= 40:
        rating = "Moderate Consumer"
        rating_color = "#F59E0B"
    else:
        rating = "High Footprint"
        rating_color = "#EF4444"
        
    return jsonify({
        'total_co2_kg': total_co2,
        'per_capita_co2_kg': per_capita_co2,
        'eco_impact_score': eco_impact_score,
        'rating': rating,
        'rating_color': rating_color,
        'breakdown': {
            'electricity': {'co2_kg': co2_electricity, 'percent': round((co2_electricity / max(1, total_co2)) * 100, 1)},
            'transport': {'co2_kg': co2_transport, 'percent': round((co2_transport / max(1, total_co2)) * 100, 1)},
            'water': {'co2_kg': co2_water, 'percent': round((co2_water / max(1, total_co2)) * 100, 1)},
            'waste': {'co2_kg': co2_waste, 'percent': round((co2_waste / max(1, total_co2)) * 100, 1)},
            'paper': {'co2_kg': co2_paper, 'percent': round((co2_paper / max(1, total_co2)) * 100, 1)}
        }
    })

@app.route('/api/solar/calculate', methods=['POST'])
def calculate_solar():
    """
    Module 2: Energy & Solar Calculator
    Estimates solar potential, financial savings, subsidy and payback period.
    """
    data = request.get_json() or {}
    roof_area_sqft = float(data.get('roof_area_sqft', 500.0))
    monthly_bill_inr = float(data.get('monthly_bill_inr', 2500.0))
    unit_tariff_inr = float(data.get('unit_tariff_inr', 7.5))
    
    # 1 kW requires ~ 100 sq.ft of shadow-free rooftop area
    # Max feasible capacity based on 80% usable roof
    usable_area = roof_area_sqft * 0.8
    max_capacity_by_roof = round(usable_area / 100.0, 1)
    
    # Capacity needed based on consumption
    monthly_units_consumed = monthly_bill_inr / unit_tariff_inr
    # 1 kW generates approx 120-130 kWh/month in North India
    capacity_needed = round(monthly_units_consumed / 125.0, 1)
    
    # Recommended capacity
    recommended_kw = min(max_capacity_by_roof, max(1.0, capacity_needed))
    recommended_kw = round(recommended_kw, 1)
    
    # Generation & Savings
    monthly_generation_kwh = round(recommended_kw * 125.0, 1)
    monthly_savings_inr = round(monthly_generation_kwh * unit_tariff_inr, 2)
    annual_savings_inr = round(monthly_savings_inr * 12.0, 2)
    
    # System cost: approx ₹60,000 per kW
    gross_cost = recommended_kw * 60000.0
    
    # PM Surya Ghar Muft Bijli Yojana Subsidy
    # 1 kW = ₹30,000; 2 kW = ₹60,000; 3 kW+ = ₹78,000
    if recommended_kw <= 1.2:
        subsidy = 30000.0
    elif recommended_kw <= 2.2:
        subsidy = 60000.0
    else:
        subsidy = 78000.0
    subsidy = min(subsidy, gross_cost * 0.6)
    
    net_cost = gross_cost - subsidy
    payback_years = round(net_cost / max(1.0, annual_savings_inr), 1)
    
    # Lifetime carbon offset (25 years)
    co2_offset_tonnes = round((monthly_generation_kwh * 12 * 25 * 0.82) / 1000.0, 1)
    equivalent_trees_planted = int(co2_offset_tonnes * 45)
    
    return jsonify({
        'recommended_capacity_kw': recommended_kw,
        'monthly_generation_kwh': monthly_generation_kwh,
        'monthly_savings_inr': monthly_savings_inr,
        'annual_savings_inr': annual_savings_inr,
        'gross_cost_inr': round(gross_cost, 2),
        'subsidy_inr': round(subsidy, 2),
        'net_investment_inr': round(net_cost, 2),
        'payback_period_years': payback_years,
        'lifetime_co2_offset_tonnes': co2_offset_tonnes,
        'equivalent_trees': equivalent_trees_planted
    })

@app.route('/api/predict/electricity', methods=['POST'])
def predict_electricity():
    """
    Module 5: Analytics & Predictive Model (Linear Regression)
    """
    data = request.get_json() or {}
    family_members = int(data.get('family_members', 4))
    house_area_sqft = float(data.get('house_area_sqft', 1200.0))
    current_month = int(data.get('current_month', 5))
    current_kwh = float(data.get('current_kwh', 350.0))
    
    forecast = ml.predict_next_month_electricity(
        family_members=family_members,
        house_area_sqft=house_area_sqft,
        current_month=current_month,
        current_kwh=current_kwh
    )
    return jsonify(forecast)

@app.route('/api/cluster/user', methods=['POST'])
def cluster_user_route():
    data = request.get_json() or {}
    kwh = float(data.get('electricity_kwh', 300.0))
    water = float(data.get('water_litres', 12000.0))
    co2 = float(data.get('total_co2_kg', 350.0))
    score = float(data.get('eco_impact_score', 65.0))
    
    result = ml.cluster_user(kwh, water, co2, score)
    return jsonify(result)

@app.route('/api/recommendations', methods=['POST'])
def get_recommendations():
    """
    Module 4: 'Give Back to Nature' Engine & Eco Points
    Generates personalized recommendations based on usage patterns.
    """
    data = request.get_json() or {}
    kwh = float(data.get('electricity_kwh', 300.0))
    commute_km = float(data.get('commute_km', 300.0))
    transport_mode = data.get('transport_mode', 'petrol_car')
    waste_kg = float(data.get('waste_kg', 25.0))
    water_litres = float(data.get('water_litres', 14000.0))
    
    recommendations = []
    
    # Electricity analysis
    if kwh > 300:
        recommendations.append({
            'id': 'rec_solar',
            'category': 'Energy',
            'title': 'Rooftop Solar Assessment',
            'action': 'Your electricity consumption is high. Installing a 2kW rooftop solar can reduce your bill by up to 70%.',
            'potential_co2_saved_kg': 240,
            'eco_points': 50,
            'difficulty': 'High Impact'
        })
        recommendations.append({
            'id': 'rec_ac_temp',
            'category': 'Energy',
            'title': 'Optimize AC Temperature to 24°C',
            'action': 'Setting AC to 24°C instead of 18-20°C saves up to 24% electricity per degree raised.',
            'potential_co2_saved_kg': 45,
            'eco_points': 25,
            'difficulty': 'Easy'
        })
    else:
        recommendations.append({
            'id': 'rec_standby',
            'category': 'Energy',
            'title': 'Eliminate Phantom Power',
            'action': 'Turn off appliances and chargers at switchboards when not in use.',
            'potential_co2_saved_kg': 15,
            'eco_points': 15,
            'difficulty': 'Easy'
        })
        
    # Transport analysis
    if commute_km > 200 and 'car' in transport_mode:
        recommendations.append({
            'id': 'rec_metro',
            'category': 'Transport',
            'title': 'Switch 2 Days/Week to Metro or Carpool',
            'action': 'Switching 2 commute days to Rapid Rail/Metro or carpool saves fuel money and cuts 60kg CO2.',
            'potential_co2_saved_kg': 60,
            'eco_points': 40,
            'difficulty': 'Medium'
        })
    elif '2wheeler' in transport_mode:
        recommendations.append({
            'id': 'rec_ev',
            'category': 'Transport',
            'title': 'Maintain Proper Tyre Pressure',
            'action': 'Keeping optimal tyre pressure increases mileage by 5-10% and cuts emissions.',
            'potential_co2_saved_kg': 12,
            'eco_points': 20,
            'difficulty': 'Easy'
        })
        
    # Waste analysis
    if waste_kg > 20:
        recommendations.append({
            'id': 'rec_compost',
            'category': 'Waste & Soil',
            'title': 'Start Balcony Kitchen Composting',
            'action': 'Convert wet kitchen waste into nutrient-rich compost, preventing methane generation at landfills.',
            'potential_co2_saved_kg': 18,
            'eco_points': 35,
            'difficulty': 'Medium'
        })
        
    # Give Back to Nature activities
    recommendations.append({
        'id': 'rec_plant_tree',
        'category': 'Give Back',
        'title': 'Plant or Adopt a Local Neem/Peepal Sapling',
        'action': 'Plant a native tree in your colony park or balcony. A single mature tree absorbs ~22kg CO2/year.',
        'potential_co2_saved_kg': 22,
        'eco_points': 100,
        'difficulty': 'Rewarding'
    })
    
    recommendations.append({
        'id': 'rec_ewaste',
        'category': 'Give Back',
        'title': 'Responsible E-Waste Recycling',
        'action': 'Drop old cables, phones, and batteries at an authorized CPCB recycling center.',
        'potential_co2_saved_kg': 25,
        'eco_points': 45,
        'difficulty': 'Medium'
    })
    
    return jsonify({
        'total_recommendations': len(recommendations),
        'potential_total_co2_saved_kg': sum(r['potential_co2_saved_kg'] for r in recommendations),
        'potential_eco_points': sum(r['eco_points'] for r in recommendations),
        'items': recommendations
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print(f"EcoBalance API server running on port {port}...")
    app.run(host='0.0.0.0', port=port, debug=False)
