"""
EcoBalance - Household Consumption Dataset Generator
Generates realistic monthly resource usage records for household sustainability analysis.
Includes seasonal trends, family sizes, and behavioral variability.
"""

import numpy as np
import pandas as pd
import os

def generate_household_data(num_samples: int = 600, random_state: int = 42) -> pd.DataFrame:
    np.random.seed(random_state)
    
    # Months 1 to 12
    months = np.random.randint(1, 13, size=num_samples)
    family_members = np.random.choice([1, 2, 3, 4, 5, 6], size=num_samples, p=[0.1, 0.25, 0.25, 0.25, 0.1, 0.05])
    house_area_sqft = np.random.normal(1200, 400, size=num_samples).clip(400, 3500)
    
    # Seasonal multiplier for electricity (Ghaziabad / North India: peaks in May-August due to AC)
    # Month 5-8 = Summer (1.4 - 1.8x), Month 12-1 = Winter (0.8 - 1.1x)
    seasonal_factors = {
        1: 0.85, 2: 0.90, 3: 1.05, 4: 1.30, 5: 1.65, 6: 1.75,
        7: 1.60, 8: 1.50, 9: 1.30, 10: 1.05, 11: 0.90, 12: 0.85
    }
    season_multipliers = np.array([seasonal_factors[m] for m in months])
    
    # Base electricity (kWh) per person per month ~ 60 - 100 kWh
    base_electricity = family_members * np.random.normal(80, 20, size=num_samples)
    electricity_kwh = (base_electricity * season_multipliers).clip(40, 1200).round(1)
    
    # Water consumption (litres per person per day * 30 days) ~ 120 - 160 LPD
    water_litres = (family_members * np.random.normal(135 * 30, 200, size=num_samples)).clip(1000, 35000).round(0)
    
    # Commute km per month (two-wheeler or car or public transit)
    commute_km = np.random.normal(350, 180, size=num_samples).clip(20, 1500).round(0)
    transport_mode = np.random.choice(
        ['petrol_2wheeler', 'petrol_car', 'diesel_car', 'ev', 'public_transport'],
        size=num_samples,
        p=[0.35, 0.30, 0.15, 0.05, 0.15]
    )
    
    # Waste generation (kg per month) ~ 0.45 kg/person/day
    waste_kg = (family_members * np.random.normal(0.45 * 30, 3, size=num_samples)).clip(5, 120).round(1)
    
    # Paper consumption (sheets per month)
    paper_sheets = (family_members * np.random.normal(40, 15, size=num_samples)).clip(5, 500).round(0)
    
    # Emission Factors (standard India CEA / GHG Protocol):
    # Electricity: 0.82 kg CO2 / kWh
    # Transport (kg CO2 / km): petrol_car=0.17, diesel_car=0.19, petrol_2wheeler=0.04, ev=0.05, public=0.03
    # Water: 0.0003 kg CO2 / L
    # Waste: 0.45 kg CO2 / kg
    # Paper: 0.005 kg CO2 / sheet
    transport_factors = {
        'petrol_car': 0.17,
        'diesel_car': 0.19,
        'petrol_2wheeler': 0.04,
        'ev': 0.05,
        'public_transport': 0.03
    }
    
    co2_electricity = electricity_kwh * 0.82
    co2_transport = np.array([km * transport_factors[mode] for km, mode in zip(commute_km, transport_mode)])
    co2_water = water_litres * 0.0003
    co2_waste = waste_kg * 0.45
    co2_paper = paper_sheets * 0.005
    
    total_co2_kg = (co2_electricity + co2_transport + co2_water + co2_waste + co2_paper).round(1)
    
    # Indian benchmark ~ 250 kg CO2 / capita / month
    benchmark = family_members * 220
    eco_impact_score = np.clip(100 - (total_co2_kg / benchmark) * 45, 10, 98).round(1)
    
    # Monthly Bill estimation in INR (UPPCL tariff structure approx ₹6.5 to ₹8.0/unit)
    bill_inr = np.where(
        electricity_kwh <= 150,
        electricity_kwh * 5.5,
        np.where(
            electricity_kwh <= 300,
            150 * 5.5 + (electricity_kwh - 150) * 6.5,
            150 * 5.5 + 150 * 6.5 + (electricity_kwh - 300) * 7.5
        )
    ).round(2)
    
    df = pd.DataFrame({
        'month': months,
        'family_members': family_members,
        'house_area_sqft': house_area_sqft.round(0),
        'electricity_kwh': electricity_kwh,
        'water_litres': water_litres,
        'commute_km': commute_km,
        'transport_mode': transport_mode,
        'waste_kg': waste_kg,
        'paper_sheets': paper_sheets,
        'total_co2_kg': total_co2_kg,
        'eco_impact_score': eco_impact_score,
        'monthly_bill_inr': bill_inr
    })
    
    return df

if __name__ == '__main__':
    data_dir = os.path.join(os.path.dirname(__file__), 'data')
    os.makedirs(data_dir, exist_ok=True)
    df = generate_household_data(600)
    csv_path = os.path.join(data_dir, 'household_consumption_dataset.csv')
    df.to_csv(csv_path, index=False)
    print(f"Dataset successfully created at: {csv_path} with {len(df)} records.")
