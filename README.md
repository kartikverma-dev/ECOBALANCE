# EcoBalance 🌿

*A data-driven sustainable living and resource management app.*
BCA project by Eva Tomar, Institute of Management Studies Ghaziabad (2024 - 2027).

An offline Android app (web app wrapped with Capacitor). It has the five modules from the synopsis plus a home dashboard:

| Module | What it does |
| --- | --- |
| **Home** | Impact score, next-month forecast, solar payback, spending, Eco Points, top suggestion |
| **My Impact** | Log monthly electricity, water, transport, food, waste and paper use, then get the Environmental Impact Score (0 - 100) and a CO2e breakdown |
| **Energy & Solar** | kWh trend, estimated bill (editable slab tariff), linear-regression forecast with MAE / RMSE, solar size, savings, payback and CO2 avoided |
| **Money** | Monthly spend breakdown and trend, plus where you can save |
| **Give Back** | Personalised "Give Back to Nature" actions, Eco Points, levels (Seed to Forest), K-Means behaviour profile |
| **Analytics** | Footprint trend, stacked category chart, history table, model report, settings, backup / restore |

## Get the APK using GitHub (no Android Studio needed)

1. Create a new repository on GitHub (any name).
2. Upload **everything inside this folder**, including the hidden `.github` folder, to the repository root. Easiest: extract the zip, then drag all files and folders into the repo page, or use `git`.
3. Open the **Actions** tab. The *Build Android APK* workflow runs automatically on every push. You can also run it with **Run workflow**.
4. When it finishes (about 5 - 8 minutes), open the run and download the **EcoBalance-debug-apk** artifact at the bottom. Unzip it to get `app-debug.apk`.
5. Copy the APK to your phone and install it. Allow "Install unknown apps" when asked.

The workflow installs dependencies, runs the logic tests, generates the Android project (`npx cap add android`), and builds the debug APK with Gradle.

## Run it in a browser (optional)

Open `www/index.html` in any browser. No server is needed. To run the tests: `npm install && npm test`.

## How it maps to the synopsis

- **Pipeline:** User Input → Storage → Processing → Calculations → ML prediction & recommendations → Dashboard. All of it runs on the phone.
- **Regression:** linear regression forecasts next-month electricity use (`www/js/ml.js`), validated with leave-one-out MAE and in-sample RMSE.
- **Clustering:** K-Means groups the household as *Eco Champion*, *Balanced Liver* or *High-Impact Household*. The reference households are synthetic and only illustrate the technique.
- **Rule-based scoring and recommendations:** `www/js/calc.js`.
- **Storage:** the synopsis lists Flask + MySQL. This build keeps data on the device (localStorage) so the APK works offline with no server. The calculation and ML modules are in JavaScript for the same reason, and are easy to port to Python/Flask if your examiners expect that stack.
- **Honesty note:** all carbon, bill and solar figures are approximations from standard factors and are labelled as estimates in the app. Editable assumptions are in Analytics → Settings.

## Project layout

```
www/                 the app (HTML, CSS, JS)
  js/calc.js         emission factors, score, bills, solar, recommendations, points
  js/ml.js           regression forecast + K-Means
  js/store.js        on-device storage
  js/charts.js       offline canvas charts
  js/app.js          screens and actions
tests/calc.test.js   unit tests (calculation validation)
capacitor.config.json
.github/workflows/build-apk.yml
```

The APK is a *debug* build, which is fine for demos and installing on your own phone. A signed release build is needed only for the Play Store.
