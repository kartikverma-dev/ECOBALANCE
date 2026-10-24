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

**EcoBalance** is an integrated Android mobile & web application designed to help individuals and households measure, manage, and reduce their environmental footprint while optimizing monthly financial expenses. 

Unlike conventional calculators that treat sustainability as an abstract idea, EcoBalance converts everyday lifestyle inputs into clear, measurable insights backed by standard GHG emission factors and machine learning predictions.

The application connects three vital dimensions:
1. **Environmental Footprint Awareness** (Carbon emissions across 5 lifestyle domains)
2. **Financial Savings** (Electricity bills, solar ROI, potential monthly reductions)
3. **Data-Driven Personalization** (Machine Learning forecasting & tailored "Give Back to Nature" recommendations)

---

## 🏛️ Five Core Modules from BCA Synopsis

| Module | Features & Implementation |
| --- | --- |
| **Home Dashboard** | Real-time Eco Impact Score ring gauge (0-100), next-month forecast, quick resource stats (kWh, L, ₹), Eco Points level, and top green action. |
| **Module 1: My Impact** | Log monthly electricity, water, commute (petrol car, diesel, 2-wheeler, EV, metro), waste and paper use; live CO2e footprint & Eco Impact Score. |
| **Module 2: Energy & Solar** | Sizing rooftop solar (kW), monthly generation, bill savings, **PM Surya Ghar** subsidy calculator, net investment, and payback period. |
| **Module 3: Money & Savings** | Monthly utility cost breakdown across electricity, fuel, water, and sanitation with 10%, 20%, 30% savings simulator. |
| **Module 4: Give Back to Nature** | Personalized action engine (sapling plantation, AC 24°C, e-waste recycling) rewarding real-time **Eco Points**, badges, and **K-Means** behavioral personas. |
| **Module 5: Analytics & ML Forecast** | **Linear Regression next-month electricity forecasting**, 6-month seasonal trend charts, model accuracy metrics (MAE/RMSE), and cluster analysis. |

---

## 📲 How to Get the Compiled APK from GitHub Actions

The repository has an automated CI/CD pipeline (`.github/workflows/build-apk.yml`) that compiles the Android APK on every push:

1. Open your repository on GitHub: [`https://github.com/kartikverma-dev/ECOBALANCE`](https://github.com/kartikverma-dev/ECOBALANCE)
2. Click on the **Actions** tab at the top.
3. Click on the latest workflow run: **Build Android APK**.
4. Scroll down to the **Artifacts** section at the bottom.
5. Download **`EcoBalance-debug-apk`**. Unzip it to get `app-debug.apk`.
6. Transfer the `.apk` file to your Android phone, tap to install, and enjoy EcoBalance!

---

## 🛠️ Project Layout & Stack

```
ECOBALANCE/
├── .github/workflows/
│   └── build-apk.yml          # GitHub Actions workflow: Android APK build + ML tests
├── www/                       # Android & Web application (Capacitor offline-first)
│   ├── index.html             # Dashboard and 5 module screens
│   ├── css/style.css          # Eco-friendly Material design theme
│   └── js/
│       ├── calc.js            # Standard GHG emission factors, bill tariffs & solar logic
│       ├── ml.js              # In-app Linear Regression forecaster & K-Means clustering
│       ├── charts.js          # Interactive canvas trend & breakdown charts
│       ├── store.js           # Local offline storage engine
│       └── app.js             # Navigation and controller logic
├── tests/
│   └── calc.test.js           # Node.js calculation validation tests
├── backend/                   # Python Flask & Scikit-Learn Data Science component
│   ├── app.py                 # REST API server
│   ├── generate_dataset.py    # Realistic household consumption dataset generator
│   ├── ml_pipeline.py         # Ridge Regression & K-Means clustering pipeline
│   ├── train_models.py        # ML training and evaluation script
│   ├── test_calculations.py   # Python unit test suite
│   └── requirements.txt       # Python dependencies
├── mobile_app/                # Flutter source code alternative
├── capacitor.config.json      # Android wrapper configuration
├── package.json               # Node dependencies & test scripts
└── README.md
```

---

## 💻 Running Locally

### 1. Run the Web/Mobile App in Browser
Simply open `www/index.html` in any web browser, or run:
```bash
npm install
npm test
```

### 2. Run the Python Machine Learning Backend
```bash
cd backend
pip install -r requirements.txt
python train_models.py
python test_calculations.py
python app.py
```

---

## 📜 Academic Declaration
This project is submitted in partial fulfillment for the award of the degree of **Bachelor of Computer Application (BCA)** at **Institute of Management Studies (IMS) Ghaziabad (University Courses Campus)** under the guidance of **Ms. Rashmi Vaishnav**.
