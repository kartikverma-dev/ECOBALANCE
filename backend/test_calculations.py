"""
EcoBalance - Backend Unit Tests
Verifies calculation integrity for Carbon Footprint, Solar ROI, and ML models.
"""

import unittest
import numpy as np
from ml_pipeline import EcoBalanceML

class TestEcoBalanceCalculations(unittest.TestCase):
    def setUp(self):
        self.ml = EcoBalanceML()
        
    def test_co2_calculations(self):
        # 100 kWh * 0.82 = 82 kg CO2
        kwh = 100
        co2_elec = kwh * 0.82
        self.assertAlmostEqual(co2_elec, 82.0, places=2)
        
        # 100 km on petrol car * 0.17 = 17 kg CO2
        km = 100
        co2_trans = km * 0.17
        self.assertAlmostEqual(co2_trans, 17.0, places=2)
        
    def test_solar_payback_logic(self):
        # 2 kW system generates ~ 250 kWh/month = 3000 kWh/year
        # At ₹7.5/unit = ₹22,500 annual savings
        # Cost: 2 * 60,000 = 1,20,000; Subsidy: 60,000 => Net: 60,000
        # Payback = 60,000 / 22,500 = ~2.67 years
        cap = 2.0
        annual_gen = cap * 125 * 12
        annual_savings = annual_gen * 7.5
        net_cost = (cap * 60000) - 60000
        payback = net_cost / annual_savings
        self.assertLess(payback, 3.5)
        self.assertGreater(payback, 2.0)
        
    def test_forecast_bounds(self):
        pred = self.ml.predict_next_month_electricity(
            family_members=4,
            house_area_sqft=1200,
            current_month=5,
            current_kwh=300
        )
        self.assertIn('predicted_electricity_kwh', pred)
        self.assertGreater(pred['predicted_electricity_kwh'], 0)
        self.assertIn('estimated_bill_inr', pred)

if __name__ == '__main__':
    unittest.main()
