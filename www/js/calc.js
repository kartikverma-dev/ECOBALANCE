/* EcoBalance - calculation engine (rule-based scoring, bills, solar, recommendations).
   All factors are approximations and are labelled as estimates in the UI. */
(function (root) {
  'use strict';

  const FACTORS = {
    gridKgPerKwh: 0.82,          // approx. Indian grid emission factor
    waterKgPerLitre: 0.0003,
    transportKgPerKm: { car: 0.192, bike: 0.07, bus: 0.089, metro: 0.041, cycle: 0 },
    dietKgPerPersonMonth: { vegan: 70, vegetarian: 100, mixed: 150, nonveg: 210 },
    wasteKgPerKg: 0.5,
    paperKgPerSheet: 0.005
  };

  const SLABS = [150, 150, 200, Infinity];      // units per slab
  const DEFAULT_RATES = [5.5, 6, 6.5, 7];       // Rs per unit per slab (editable in Settings)
  const DEFAULT_SETTINGS = {
    members: 3, rates: DEFAULT_RATES.slice(),
    solarCostPerKw: 55000, solarYield: 4, subsidyPct: 0, solarKw: 0
  };

  const CATS = [
    { key: 'electricity', label: 'Electricity', color: '#f4b400' },
    { key: 'water', label: 'Water', color: '#4aa3df' },
    { key: 'transport', label: 'Transport', color: '#e8710a' },
    { key: 'food', label: 'Food', color: '#7cb342' },
    { key: 'waste', label: 'Waste', color: '#8d6e63' },
    { key: 'paper', label: 'Paper', color: '#9e9e9e' }
  ];

  const n = (v) => { const x = parseFloat(v); return isFinite(x) && x > 0 ? x : 0; };
  const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
  const round = (v, d = 0) => { const p = Math.pow(10, d); return Math.round(v * p) / p; };

  function billFor(kwh, rates) {
    rates = rates || DEFAULT_RATES;
    let left = n(kwh), bill = 0;
    for (let i = 0; i < SLABS.length && left > 0; i++) {
      const use = Math.min(left, SLABS[i]);
      bill += use * rates[i];
      left -= use;
    }
    return bill;
  }

  function footprint(e, s) {
    s = s || DEFAULT_SETTINGS;
    const t = FACTORS.transportKgPerKm;
    const fp = {
      electricity: n(e.electricityKwh) * FACTORS.gridKgPerKwh,
      water: n(e.waterL) * FACTORS.waterKgPerLitre,
      transport: n(e.carKm) * t.car + n(e.bikeKm) * t.bike + n(e.busKm) * t.bus +
                 n(e.metroKm) * t.metro + n(e.cycleKm) * t.cycle,
      food: (FACTORS.dietKgPerPersonMonth[e.diet] || FACTORS.dietKgPerPersonMonth.mixed) * Math.max(1, n(s.members)),
      waste: n(e.wasteKg) * FACTORS.wasteKgPerKg,
      paper: n(e.paperSheets) * FACTORS.paperKgPerSheet
    };
    fp.total = fp.electricity + fp.water + fp.transport + fp.food + fp.waste + fp.paper;
    return fp;
  }

  // Environmental Impact Score: 100 = zero footprint, 50 = 160 kg CO2e per person per month
  // (roughly the Indian per-capita average), 0 = 320 kg or more per person per month.
  function score(total, members) {
    const pp = total / Math.max(1, n(members));
    return Math.round(clamp(100 - (pp / 320) * 100, 0, 100));
  }

  function grade(sc) {
    if (sc >= 75) return { label: 'Excellent', color: '#2e9e5b' };
    if (sc >= 55) return { label: 'Good', color: '#7cb342' };
    if (sc >= 35) return { label: 'Fair', color: '#f4b400' };
    return { label: 'Needs work', color: '#e8710a' };
  }

  function elecBill(e, s) {
    return n(e.costElectricity) > 0 ? n(e.costElectricity) : billFor(e.electricityKwh, (s || DEFAULT_SETTINGS).rates);
  }

  function spend(e, s) {
    const r = {
      electricity: elecBill(e, s), water: n(e.costWater), transport: n(e.costTransport),
      food: n(e.costFood), other: n(e.costOther)
    };
    r.total = r.electricity + r.water + r.transport + r.food + r.other;
    return r;
  }

  function solar(avgKwh, s) {
    s = Object.assign({}, DEFAULT_SETTINGS, s || {});
    avgKwh = n(avgKwh);
    if (avgKwh <= 0) return null;
    const days = 30, y = n(s.solarYield) || 4;
    const autoKw = Math.max(1, Math.ceil((avgKwh / (y * days)) * 2) / 2);
    const kw = n(s.solarKw) > 0 ? n(s.solarKw) : autoKw;
    const gen = kw * y * days;
    const offset = Math.min(gen, avgKwh);
    const billNow = billFor(avgKwh, s.rates), billAfter = billFor(avgKwh - offset, s.rates);
    const monthlySaving = billNow - billAfter;
    const gross = kw * n(s.solarCostPerKw);
    const net = gross * (1 - clamp(n(s.subsidyPct), 0, 100) / 100);
    const payback = monthlySaving > 0 ? net / (monthlySaving * 12) : null;
    return {
      kw, autoKw, gen, offset, billNow, billAfter, monthlySaving, gross, net, payback,
      co2Avoided: offset * FACTORS.gridKgPerKwh,
      saving25y: monthlySaving * 12 * 25 - net
    };
  }

  function recommend(e, s, sol) {
    s = s || DEFAULT_SETTINGS;
    const m = Math.max(1, n(s.members)), t = FACTORS.transportKgPerKm, out = [];
    const add = (id, icon, title, why, savingKg, savingInr, points) =>
      out.push({ id, icon, title, why, savingKg: round(savingKg, 1), savingInr: Math.round(savingInr || 0), points });

    const kwh = n(e.electricityKwh);
    if (kwh / m > 90) {
      add('cut-power', '💡', 'Cut electricity use by 10%',
        'Your usage is ' + Math.round(kwh / m) + ' kWh per person. Set the AC to 24-26 °C, switch to LED/5-star appliances, unplug standby devices.',
        kwh * 0.1 * FACTORS.gridKgPerKwh, billFor(kwh, s.rates) - billFor(kwh * 0.9, s.rates), 35);
    }
    const shiftKg = n(e.carKm) * 0.3 * (t.car - t.metro) + n(e.bikeKm) * 0.3 * (t.bike - t.metro);
    if (shiftKg >= 3) {
      add('commute', '🚇', 'Shift 30% of car/bike trips to metro, bus or cycling',
        'Low-emission commuting cuts the largest travel emissions you log.', shiftKg, 0, 40);
    }
    if (n(e.waterL) / m > 4500) {
      add('water', '💧', 'Fix leaks and trim water use by 15%',
        'You use about ' + Math.round(n(e.waterL) / m / 30) + ' L per person per day. Bucket baths, tap aerators and leak checks help.',
        n(e.waterL) * 0.15 * FACTORS.waterKgPerLitre, 0, 20);
    }
    const dietF = FACTORS.dietKgPerPersonMonth[e.diet] || 150;
    if (dietF > 100) {
      add('diet', '🥗', 'Have two plant-based days each week',
        'Food is a big part of the footprint for a ' + (e.diet === 'nonveg' ? 'non-vegetarian' : 'mixed') + ' diet.',
        (dietF - 100) * (2 / 7) * m, 0, 30);
    }
    if (n(e.paperSheets) > 150) {
      add('paper', '📄', 'Go paper-light (digital notes, print double-sided)',
        'You logged ' + Math.round(n(e.paperSheets)) + ' sheets this month.', n(e.paperSheets) * 0.5 * FACTORS.paperKgPerSheet, 0, 15);
    }
    if (n(e.wasteKg) / m > 10) {
      add('compost', '♻️', 'Segregate waste and compost kitchen scraps',
        'Cutting landfill waste by ~30% lowers methane emissions.', n(e.wasteKg) * 0.3 * FACTORS.wasteKgPerKg, 0, 25);
    }
    if (sol && kwh > 200 && sol.monthlySaving > 0) {
      add('solar', '☀️', 'Explore rooftop solar (' + sol.kw + ' kW)',
        'Estimated to cover ' + Math.round(sol.offset) + ' kWh a month. See the Energy tab for the payback estimate.',
        sol.co2Avoided, sol.monthlySaving, 60);
    }
    add('tree', '🌳', 'Plant or care for a tree this month',
      'A growing tree absorbs roughly 20 kg of CO2 a year (approximate). Join a local plantation drive.', 1.7, 0, 25);
    add('ewaste', '🔌', 'Recycle e-waste at an authorised collection point',
      'Keeps toxic material out of landfill and recovers metals.', 0, 0, 30);

    out.sort((a, b) => (b.savingKg + b.points / 100) - (a.savingKg + a.points / 100));
    return out;
  }

  const LEVELS = [
    { name: 'Seed', min: 0 }, { name: 'Sprout', min: 100 }, { name: 'Sapling', min: 300 },
    { name: 'Tree', min: 600 }, { name: 'Forest', min: 1000 }
  ];

  function level(pts) {
    let i = 0;
    for (let k = 0; k < LEVELS.length; k++) if (pts >= LEVELS[k].min) i = k;
    const cur = LEVELS[i], next = LEVELS[i + 1] || null;
    return {
      name: cur.name, next: next ? next.name : null, toNext: next ? next.min - pts : 0,
      progress: next ? (pts - cur.min) / (next.min - cur.min) : 1
    };
  }

  // Eco Points: +20 per month logged, +30 when the footprint drops vs the previous month, + completed actions.
  function points(state) {
    const months = Object.keys(state.entries).sort();
    let p = months.length * 20, prev = null;
    months.forEach((m) => {
      const t = footprint(state.entries[m], state.settings).total;
      if (prev !== null && t < prev) p += 30;
      prev = t;
    });
    (state.done || []).forEach((d) => { p += d.points || 0; });
    return p;
  }

  const api = { FACTORS, SLABS, DEFAULT_RATES, DEFAULT_SETTINGS, CATS, LEVELS, billFor, footprint, score, grade,
    elecBill, spend, solar, recommend, level, points, n, round };
  if (typeof module !== 'undefined' && module.exports) module.exports = api; else root.Calc = api;
})(typeof window !== 'undefined' ? window : globalThis);
