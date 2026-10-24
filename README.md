# 🌿 EcoBalance - A Data-Driven Sustainable Living and Resource Management Application

> **“Measure your impact. Save your resources. Give back to the environment.”**

---

### 🎓 Academic Project Information
- **Degree:** Bachelor of Computer Applications (BCA) — Batch 2024–2027
- **Submitted by:** **Eva Tomar** (University Roll No: `240935106093`)
- **Under the Guidance of:** **Ms. Rashmi Vaishnav**
- **Institution:** **Institute of Management Studies (IMS) Ghaziabad (University Courses Campus)**
- **Address:** NH-24, Adhyatmik Nagar, Ghaziabad (U.P)

---

## 📖 About the Application

**EcoBalance** is an integrated full-stack and mobile application designed to help individuals and households measure, manage, and reduce their environmental footprint while optimizing monthly financial expenses. 

Unlike conventional calculators that treat sustainability as an abstract idea, EcoBalance converts everyday lifestyle inputs into clear, measurable insights backed by standard GHG emission factors and machine learning predictions.

The application connects three vital dimensions:
1. **Environmental Footprint Awareness** (Carbon emissions across 5 lifestyle domains)
2. **Financial Savings** (Electricity bills, solar ROI, potential monthly reductions)
3. **Data-Driven Personalization** (Machine Learning forecasting & tailored "Give Back to Nature" recommendations)

---

## 🏛️ System Architecture & Five Core Modules

```
                        ┌──────────────────────────────────────────────┐
                        │              EcoBalance App                  │
                        │        (Flutter Mobile / Web UI)             │
                        └──────────────────────┬───────────────────────┘
                                               │
       ┌──────────────────┬────────────────────┼───────────────────┬──────────────────┐
       ▼                  ▼                    ▼                   ▼                  ▼
┌──────────────┐  ┌──────────────┐     ┌──────────────┐    ┌──────────────┐   ┌──────────────┐
│  Module 1    │  │  Module 2    │     │  Module 3    │    │  Module 4    │   │  Module 5    │
│  My Impact   │  │Energy & Solar│     │    Money     │    │  Give Back   │   │  Analytics   │
│              │  │              │     │              │    │              │   │  & Forecast  │
│• Carbon kg   │  │• Sizing (kW) │     │• Bill Trends │    │• Action Recs │   │• Linear Reg. │
│• 5 Domains   │  │• Subsidy Est │     │• Cost Tiers  │    │• Eco Points  │   │• Next-Mo kWh │
│• Eco Score   │  │• Payback ROI │     │• Savings Sim │    │• Badges      │   │• K-Means Cl. │
└──────────────┘  └──────────────┘     └──────────────┘    └──────────────┘   └──────────────┘
                                               │
                                 ┌─────────────┴─────────────┐
                                 │    Python Flask REST API   │
                                 │     & Scikit-learn ML     │
                                 └───────────────────────────┘
```

### 1. Module 1: My Impact (Carbon Footprint & Eco Score)
- Tracks 5 resource domains:
  - **Electricity (kWh):** India CEA grid factor (0.82 kg CO2e / kWh)
  - **Water (Litres):** Pumping & treatment footprint (0.0003 kg CO2e / L)
  - **Transportation (km):** Petrol 2-wheeler, petrol/diesel cars, EV, public metro/bus
  - **Food & Solid Waste (kg):** Municipal landfill emissions (0.45 kg CO2e / kg)
  - **Paper Consumption (sheets):** Virgin pulp production (0.005 kg CO2e / sheet)
- Calculates a composite **Environmental Impact Score (0 to 100)** normalized against national per-capita urban benchmarks.

### 2. Module 2: Energy & Solar Calculator
- Determines rooftop solar feasibility based on usable shadow-free area (100 sq.ft / kWp).
- Calculates monthly generation (~125 kWh / kWp in Northern India).
- Estimates government subsidies under **PM Surya Ghar: Muft Bijli Yojana** (₹30,000 for 1kW, ₹60,000 for 2kW, ₹78,000 for 3kW+).
- Computes net investment, annual savings, payback period (years), and 25-year lifetime carbon offset.

### 3. Module 3: Money & Expense Management
- Analyzes monthly expenditures across electricity, water, commuting fuels, and sanitation fees.
- Simulates potential cost reductions (10%, 20%, 30%) by shifting habits.
- Highlights slab tariff thresholds (e.g. tier step-up from ₹5.50 to ₹7.50/unit above 300 units).

### 4. Module 4: "Give Back to Nature" Engine
- Replaces generic tips with **data-driven recommendations** targeting the user's highest emission sources.
- Gamified **Eco Points System**: Users complete green actions (e.g., AC temperature tuning, e-waste recycling, sapling plantation) to earn points.
- Progression tiers and unlockable achievement badges: *Seedling Starter*, *Energy Saver*, *Solar Pioneer*, *Earth Guardian*.

### 5. Module 5: Analytics & Machine Learning Forecast
- **Electricity Consumption Forecaster:** Trained using Scikit-Learn **Linear/Ridge Regression** ($R^2 \approx 0.988$, $MAE \approx 16.2\text{ kWh}$) using family size, house area, seasonality, and previous month consumption.
- **Behavioral Clustering:** **K-Means Clustering ($k=3$)** grouping users into *Eco Champion*, *Balanced Consumer*, and *High Resource User*.

---

## 🚀 How GitHub Automatically Builds the APK

This repository is equipped with a GitHub Actions CI/CD pipeline (`.github/workflows/build-apk.yml`). Every time you push code to GitHub:
1. GitHub Actions starts an **Ubuntu runner**.
2. Installs **JDK 17** and **Flutter SDK**.
3. Compiles the Android Release APK (`flutter build apk --release`).
4. Generates an installable **`app-release.apk`** artifact and attaches it to GitHub Releases!

### 📥 Downloading Your APK from GitHub:
1. Go to your repository on GitHub.
2. Click on the **Actions** tab at the top.
3. Click on the latest workflow run: **Build EcoBalance Android APK**.
4. Scroll down to the **Artifacts** section at the bottom.
5. Click **EcoBalance-Release-APK** to download the zip containing `app-release.apk`.
6. Transfer the `.apk` file to your Android phone, tap install, and run!

---

## 🛠️ Local Development & Running

### 1. Python Backend (Flask & ML Pipeline)
```bash
# Navigate to backend directory
cd backend

# Install dependencies
pip install -r requirements.txt

# Run ML dataset generation and training
python train_models.py

# Run unit tests
python test_calculations.py

# Start Flask REST API server
python app.py
```
*API will run at `http://localhost:5000` with endpoints `/api/health`, `/api/impact/calculate`, `/api/solar/calculate`, `/api/predict/electricity`, `/api/recommendations`.*

### 2. Flutter Mobile App
```bash
# Navigate to mobile app directory
cd mobile_app

# Fetch dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## 📂 Project Directory Structure

```
EcoBalance_BCA_Synopsis/
├── .github/
│   └── workflows/
│       └── build-apk.yml            # CI/CD Workflow for GitHub Actions APK Build
├── backend/
│   ├── app.py                       # Flask REST API server
│   ├── generate_dataset.py          # Realistic household consumption dataset generator
│   ├── ml_pipeline.py               # Ridge Regression forecaster & K-Means clustering
│   ├── train_models.py              # ML model trainer & evaluator
│   ├── test_calculations.py         # Pytest/Unittest suite
│   ├── requirements.txt             # Python dependencies
│   ├── data/                        # Generated dataset CSV
│   └── models/                      # Serialized ML model artifacts (.pkl)
├── mobile_app/
│   ├── pubspec.yaml                 # Flutter configuration & dependencies
│   └── lib/
│       ├── main.dart                # App entry point & bottom navigation
│       ├── models/
│       │   └── resource_data.dart   # Domain entities & calculation models
│       ├── services/
│       │   └── eco_engine.dart      # Client-side offline calculation & ML engine
│       └── screens/
│           ├── dashboard_screen.dart        # Home dashboard with Eco Score gauge
│           ├── my_impact_screen.dart        # Module 1: My Impact form & breakdown
│           ├── solar_calculator_screen.dart # Module 2: Energy & Solar ROI calculator
│           ├── money_expenses_screen.dart   # Module 3: Monthly spend & savings simulator
│           ├── give_back_screen.dart        # Module 4: Give Back engine & Eco Points
│           └── analytics_screen.dart        # Module 5: Analytics & ML forecast
├── .gitignore
├── EcoBalance_BCA_Synopsis.docx     # Academic synopsis document
└── README.md
```

---

## 📜 Academic Declaration
This project is submitted in partial fulfillment for the award of the degree of **Bachelor of Computer Application (BCA)** at **Institute of Management Studies (IMS) Ghaziabad (University Courses Campus)** under the guidance of **Ms. Rashmi Vaishnav**.
