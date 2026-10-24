"""
EcoBalance - Model Training Script
Generates training data, trains Linear Regression & K-Means models,
evaluates performance metrics (MAE, RMSE, R2 Score), and persists trained artifacts.
"""

import os
from generate_dataset import generate_household_data
from ml_pipeline import EcoBalanceML

def main():
    print("=" * 60)
    print("  EcoBalance Machine Learning Training Pipeline")
    print("  IMS Ghaziabad - BCA Project - Eva Tomar")
    print("=" * 60)
    
    base_dir = os.path.dirname(__file__)
    data_dir = os.path.join(base_dir, 'data')
    models_dir = os.path.join(base_dir, 'models')
    os.makedirs(data_dir, exist_ok=True)
    os.makedirs(models_dir, exist_ok=True)
    
    print("\n[1/3] Generating synthetic household consumption dataset (600 records)...")
    df = generate_household_data(600)
    csv_file = os.path.join(data_dir, 'household_consumption_dataset.csv')
    df.to_csv(csv_file, index=False)
    print(f"      Saved to {csv_file}")
    
    print("\n[2/3] Training Electricity Consumption Regression Forecaster...")
    ml = EcoBalanceML()
    metrics = ml.train_regression_model(df)
    print(f"      Model Performance:")
    print(f"      - Mean Absolute Error (MAE): {metrics['mae']} kWh")
    print(f"      - Root Mean Squared Error (RMSE): {metrics['rmse']} kWh")
    print(f"      - R-squared (R2 Score): {metrics['r2_score']}")
    
    print("\n[3/3] Training K-Means Clustering for User Personas (k=3)...")
    cluster_metrics = ml.train_clustering_model(df, n_clusters=3)
    print(f"      K-Means Inertia: {round(cluster_metrics['inertia'], 2)}")
    
    print("\nSaving trained models to 'models/' directory...")
    ml.save(models_dir)
    print("Model artifacts successfully saved!")
    
    # Test sample prediction
    sample_pred = ml.predict_next_month_electricity(
        family_members=4,
        house_area_sqft=1400,
        current_month=5,
        current_kwh=380.0
    )
    print("\n--- Sample Prediction ---")
    print(f"Inputs: 4 Members, 1400 sq.ft, Month 5 (May), Current: 380 kWh")
    print(f"Forecast for Month 6 (June): {sample_pred['predicted_electricity_kwh']} kWh")
    print(f"Estimated June Bill: Rs. {sample_pred['estimated_bill_inr']}")
    print(f"Trend: {sample_pred['trend']} ({sample_pred['percentage_change']}%)")
    print("=" * 60)

if __name__ == '__main__':
    main()
