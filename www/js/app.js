/* EcoBalance - UI controller. Five modules: My Impact, Energy & Solar, Money, Give Back, Analytics + Home. */
(function () {
  'use strict';
  const $ = (s, r) => (r || document).querySelector(s);
  const C = window.Calc, M = window.Ml;
  let state = Store.load();
  let tab = 'home', formMonth = null, showBackup = false;
  const TABS = [['home', '🏠', 'Home'], ['impact', '🌍', 'My Impact'], ['energy', '⚡', 'Energy'],
    ['money', '💰', 'Money'], ['give', '🌱', 'Give Back'], ['stats', '📊', 'Analytics']];

  const fmt = (v, d) => Number(v || 0).toLocaleString('en-IN', { maximumFractionDigits: d || 0, minimumFractionDigits: d || 0 });
  const inr = (v) => '₹' + fmt(v);
  const pad = (x) => (x < 10 ? '0' : '') + x;
  const thisMonth = () => { const d = new Date(); return d.getFullYear() + '-' + pad(d.getMonth() + 1); };
  const monthName = (m) => { const p = m.split('-').map(Number); return new Date(p[0], p[1] - 1, 1).toLocaleString('en', { month: 'long', year: 'numeric' }); };
  const persist = () => Store.save(state);
  const mean = (a) => (a.length ? a.reduce((x, y) => x + y, 0) / a.length : 0);

  function toast(msg) {
    const t = $('#toast'); t.textContent = msg; t.classList.add('on');
    clearTimeout(toast.h); toast.h = setTimeout(() => t.classList.remove('on'), 2200);
  }

  function derive() {
    const ms = Object.keys(state.entries).sort();
    const rows = ms.map((m) => {
      const e = state.entries[m], fp = C.footprint(e, state.settings);
      return { m, e, fp, score: C.score(fp.total, state.settings.members), bill: C.elecBill(e, state.settings), spend: C.spend(e, state.settings) };
    });
    return { ms, rows, last: rows[rows.length - 1], prev: rows[rows.length - 2] };
  }

  const legend = (items) => '<div class="legend">' + items.map((i) => '<span><i style="background:' + i.color + '"></i>' + i.label + '</span>').join('') + '</div>';
  const ring = (sc) => { const g = C.grade(sc); return '<div class="ring" style="--p:' + sc + ';--c:' + g.color + '"><span>' + sc + '</span></div>'; };
  const delta = (cur, prev, unit, lowerIsBetter) => {
    if (prev == null) return '';
    const d = cur - prev; if (Math.abs(d) < 0.5) return '<span class="muted small">no change vs last month</span>';
    const good = lowerIsBetter ? d < 0 : d > 0;
    return '<span class="delta ' + (good ? 'down' : 'up') + ' small">' + (d > 0 ? '▲ ' : '▼ ') + fmt(Math.abs(d)) + ' ' + unit + ' vs last month</span>';
  };
  const featFor = (r) => {
    const m = Math.max(1, state.settings.members), f = r.fp;
    return [f.electricity / m, f.transport / m, (f.food + f.water + f.waste + f.paper) / m];
  };
  const avgKwh = (d) => mean(d.rows.map((r) => C.n(r.e.electricityKwh)));
  const tiles = () => '<div class="tiles">' + TABS.slice(1).map((t) => '<button data-go="' + t[0] + '"><span>' + t[1] + '</span>' + t[2] + '</button>').join('') + '</div>';
  const empty = (why) => '<div class="card"><h2>No data yet</h2><p class="muted">' + why + '</p><button class="btn" data-go="impact">Log a month</button><button class="btn ghost" data-act="demo">Load demo data</button></div>';

  /* ---------------------------------------------------------------- HOME */
  function home() {
    const d = derive();
    if (!d.last) {
      return { html: '<section class="card"><h1>Welcome to EcoBalance 🌿</h1><p class="muted">Turn everyday electricity, water, travel, food, waste and paper use into a clear Environmental Impact Score, solar and bill estimates, a next-month forecast, and personalised “Give Back to Nature” actions.</p><button class="btn" data-go="impact">Log your first month</button><button class="btn ghost" data-act="demo">Try with demo data</button></section>' + tiles() };
    }
    const l = d.last, g = C.grade(l.score);
    const fc = M.forecastNext(d.rows.map((r) => C.n(r.e.electricityKwh)));
    const sol = C.solar(avgKwh(d), state.settings);
    const pts = C.points(state), lv = C.level(pts);
    const rec = C.recommend(l.e, state.settings, sol)[0];
    return { html:
      '<section class="card flex">' + ring(l.score) + '<div><h2 style="margin:0">' + g.label + '</h2><div class="muted small">Environmental Impact Score · ' + monthName(l.m) + '</div><div class="stat">' + fmt(l.fp.total) + ' <small>kg CO2e</small></div>' +
      delta(l.fp.total, d.prev && d.prev.fp.total, 'kg', true) + '</div></section>' +
      '<div class="grid">' +
      '<div class="card"><div class="muted small">Next-month electricity</div><div class="stat">' + fmt(fc.value) + ' <small>kWh</small></div><div class="small muted">≈ ' + inr(C.billFor(fc.value, state.settings.rates)) + '</div></div>' +
      '<div class="card"><div class="muted small">Solar payback</div><div class="stat">' + (sol && sol.payback ? fmt(sol.payback, 1) + ' <small>yrs</small>' : '–') + '</div><div class="small muted">' + (sol ? sol.kw + ' kW system' : '') + '</div></div>' +
      '<div class="card"><div class="muted small">This month’s spend</div><div class="stat">' + inr(l.spend.total) + '</div>' + delta(l.spend.total, d.prev && d.prev.spend.total, '₹', true) + '</div>' +
      '<div class="card"><div class="muted small">Eco Points</div><div class="stat">' + fmt(pts) + ' <small>' + lv.name + '</small></div><div class="bar"><i style="width:' + Math.round(lv.progress * 100) + '%"></i></div></div></div>' +
      '<div class="card" style="margin-top:12px"><h2>Top suggestion</h2><div class="rec"><div class="ic">' + rec.icon + '</div><div><b>' + rec.title + '</b><span class="muted small">' + rec.why + '</span></div></div><button class="btn sm ghost" data-go="give">See all actions</button></div>' + tiles() };
  }

  /* ---------------------------------------------------------------- IMPACT */
  const num = (name, label, unit, e) => '<label class="f"><span>' + label + '</span><div class="inp"><input type="number" inputmode="decimal" min="0" step="any" name="' + name + '" value="' + (e[name] != null && e[name] !== 0 ? e[name] : '') + '" placeholder="0"><em>' + unit + '</em></div></label>';

  function impact() {
    const d = derive();
    const month = formMonth || thisMonth();
    const e = state.entries[month] || {};
    const diets = [['vegan', 'Vegan'], ['vegetarian', 'Vegetarian'], ['mixed', 'Mixed (veg + non-veg)'], ['nonveg', 'Non-veg most days']];
    let html = '<section class="card"><h2>Log monthly usage</h2><form data-form="entry">' +
      '<label class="f"><span>Month</span><div class="inp"><input type="month" id="fmonth" name="month" value="' + month + '" required></div></label>' +
      '<h3>⚡ Electricity</h3>' + num('electricityKwh', 'Units consumed', 'kWh', e) +
      '<h3>💧 Water</h3>' + num('waterL', 'Water used (household)', 'litres', e) +
      '<h3>🚗 Transport (distance per month)</h3>' + num('carKm', 'Car', 'km', e) + num('bikeKm', 'Two-wheeler / auto', 'km', e) + num('busKm', 'Bus', 'km', e) + num('metroKm', 'Metro / train', 'km', e) + num('cycleKm', 'Cycling / walking', 'km', e) +
      '<h3>🍽️ Food, waste &amp; paper</h3><label class="f"><span>Typical diet</span><div class="inp"><select name="diet">' +
      diets.map((x) => '<option value="' + x[0] + '"' + ((e.diet || 'mixed') === x[0] ? ' selected' : '') + '>' + x[1] + '</option>').join('') + '</select></div></label>' +
      num('wasteKg', 'Household waste', 'kg', e) + num('paperSheets', 'Paper used', 'sheets', e) +
      '<h3>💰 Expenses (optional)</h3>' + num('costElectricity', 'Electricity bill (blank = estimate)', '₹', e) + num('costWater', 'Water bill', '₹', e) + num('costTransport', 'Fuel / fares', '₹', e) + num('costFood', 'Food &amp; groceries', '₹', e) + num('costOther', 'Other', '₹', e) +
      '<button class="btn" type="submit">Save ' + monthName(month) + '</button></form></section>';

    const r = d.rows.find((x) => x.m === month);
    if (r) {
      const g = C.grade(r.score), parts = C.CATS.map((c) => ({ label: c.label, color: c.color, value: r.fp[c.key] }));
      html += '<section class="card"><h2>Impact for ' + monthName(month) + '</h2><div class="flex">' + ring(r.score) + '<div><b style="color:' + g.color + '">' + g.label + '</b><div class="muted small">Score out of 100 (higher is greener)</div><div class="stat">' + fmt(r.fp.total) + ' <small>kg CO2e</small></div></div></div>' +
        '<canvas id="cDonut" class="sm"></canvas>' + legend(parts) +
        parts.map((p) => '<div class="row"><span><i style="background:' + p.color + ';display:inline-block;width:10px;height:10px;border-radius:3px;margin-right:6px"></i>' + p.label + '</span><b>' + fmt(p.value, 1) + ' kg <span class="muted small">(' + fmt((p.value / r.fp.total) * 100) + '%)</span></b></div>').join('') +
        '<div class="note">Estimates use standard emission factors (grid ≈ ' + C.FACTORS.gridKgPerKwh + ' kg/kWh, car ≈ ' + C.FACTORS.transportKgPerKm.car + ' kg/km, etc.). Score: 50 ≈ 160 kg CO2e per person a month, 0 ≈ 320 kg or more. Household size: ' + state.settings.members + ' (change in Analytics → Settings).</div></section>';
    }
    return { html, mount() {
      if (r) Charts.donut($('#cDonut'), C.CATS.map((c) => ({ value: r.fp[c.key], color: c.color })), fmt(r.fp.total));
    } };
  }

  /* ---------------------------------------------------------------- ENERGY */
  function energy() {
    const d = derive();
    if (!d.last) return { html: empty('Log at least one month of electricity use to see bills, a forecast and the solar plan.') };
    const kwh = d.rows.map((r) => C.n(r.e.electricityKwh)), fc = M.forecastNext(kwh), s = state.settings;
    const sol = C.solar(avgKwh(d), s);
    let html = '<section class="card"><h2>Electricity use (kWh)</h2><canvas id="cKwh"></canvas>' +
      '<div class="row"><span>Last month bill (' + (C.n(d.last.e.costElectricity) > 0 ? 'entered' : 'estimated') + ')</span><b>' + inr(d.last.bill) + '</b></div>' +
      '<div class="row"><span>Forecast for next month</span><b>' + fmt(fc.value) + ' kWh · ' + inr(C.billFor(fc.value, s.rates)) + '</b></div>' +
      '<div class="row"><span>Method</span><b>' + fc.method + '</b></div>' +
      (fc.r2 != null ? '<div class="row"><span>Trend</span><b>' + (fc.slope >= 0 ? '+' : '') + fmt(fc.slope, 1) + ' kWh / month · R² ' + fmt(fc.r2, 2) + '</b></div>' : '') +
      (fc.mae != null ? '<div class="row"><span>Validation error (leave-one-out)</span><b>MAE ' + fmt(fc.mae, 1) + ' · RMSE ' + fmt(fc.rmse, 1) + ' kWh</b></div>' : '') +
      '<div class="row"><span>Confidence</span><span class="tag">' + fc.confidence + '</span></div>' +
      (kwh.length < 3 ? '<div class="note">Log 3+ months to unlock the regression model; 6+ months gives better forecasts.</div>' : '') + '</section>';
    html += '<section class="card"><h2>☀️ Solar planner</h2><p class="muted small" style="margin-top:0">Based on your average of ' + fmt(avgKwh(d)) + ' kWh a month.</p>' +
      '<form data-form="solar"><label class="f"><span>System size (0 = auto-size)</span><div class="inp"><input type="number" inputmode="decimal" min="0" step="0.5" name="solarKw" value="' + (s.solarKw || '') + '" placeholder="auto: ' + sol.autoKw + '"><em>kW</em></div></label><button class="btn sm" type="submit">Recalculate</button></form>' +
      '<div class="row"><span>Recommended / chosen size</span><b>' + sol.kw + ' kW</b></div>' +
      '<div class="row"><span>Estimated generation</span><b>' + fmt(sol.gen) + ' kWh / month</b></div>' +
      '<div class="row"><span>Bill now → with solar</span><b>' + inr(sol.billNow) + ' → ' + inr(sol.billAfter) + '</b></div>' +
      '<div class="row"><span>Monthly saving</span><b>' + inr(sol.monthlySaving) + '</b></div>' +
      '<div class="row"><span>Installation cost (after ' + fmt(s.subsidyPct) + '% subsidy)</span><b>' + inr(sol.net) + '</b></div>' +
      '<div class="row"><span>Payback period</span><b>' + (sol.payback ? fmt(sol.payback, 1) + ' years' : '–') + '</b></div>' +
      '<div class="row"><span>CO2 avoided</span><b>' + fmt(sol.co2Avoided) + ' kg / month</b></div>' +
      '<div class="row"><span>Rough 25-year net benefit</span><b>' + inr(sol.saving25y) + '</b></div>' +
      '<div class="note">Estimates only. Real output depends on location, roof shade, tilt and tariff. Cost per kW (₹' + fmt(s.solarCostPerKw) + ') and yield (' + s.solarYield + ' kWh/kW/day) can be edited in Analytics → Settings.</div></section>';
    return { html, mount() { Charts.bar($('#cKwh'), d.ms, kwh, { forecast: fc.value, color: '#f4b400' }); } };
  }

  /* ---------------------------------------------------------------- MONEY */
  function money() {
    const d = derive();
    if (!d.last) return { html: empty('Log a month (with expenses) to track where your money goes.') };
    const l = d.last, sp = l.spend, sol = C.solar(avgKwh(d), state.settings);
    const items = [['Electricity', sp.electricity, '#f4b400'], ['Water', sp.water, '#4aa3df'], ['Transport', sp.transport, '#e8710a'], ['Food', sp.food, '#7cb342'], ['Other', sp.other, '#9e9e9e']];
    const max = Math.max.apply(null, items.map((i) => i[1]).concat([1]));
    const opps = C.recommend(l.e, state.settings, sol).filter((r) => r.savingInr > 0);
    const top = items.slice().sort((a, b) => b[1] - a[1])[0];
    let html = '<section class="card"><h2>' + monthName(l.m) + ' spending</h2><div class="stat">' + inr(sp.total) + '</div>' + delta(sp.total, d.prev && d.prev.spend.total, '₹', true) +
      items.map((i) => '<div class="row" style="display:block"><div class="row" style="border:0;padding:3px 0"><span>' + i[0] + '</span><b>' + inr(i[1]) + '</b></div><div class="bar"><i style="width:' + (i[1] / max) * 100 + '%;background:' + i[2] + '"></i></div></div>').join('') +
      (top[1] > 0 ? '<p class="muted small">Biggest expense: <b>' + top[0] + '</b> (' + fmt((top[1] / sp.total) * 100) + '% of spend).</p>' : '') + '</section>';
    html += '<section class="card"><h2>Monthly spend trend</h2><canvas id="cSpend"></canvas></section>';
    html += '<section class="card"><h2>Where you can save</h2>' + (opps.length ? opps.map((o) => '<div class="rec row"><div class="ic">' + o.icon + '</div><div style="flex:1"><b>' + o.title + '</b><span class="muted small">' + o.why + '</span></div><b>' + inr(o.savingInr) + '<span class="muted small">/mo</span></b></div>').join('') : '<p class="muted">Nothing flagged right now. Nice work!</p>') +
      '<div class="note">Bills are estimated from a slab tariff you can edit in Analytics → Settings.</div></section>';
    return { html, mount() { Charts.bar($('#cSpend'), d.ms, d.rows.map((r) => r.spend.total), { color: '#2e9e5b' }); } };
  }

  /* ---------------------------------------------------------------- GIVE BACK */
  function give() {
    const d = derive();
    if (!d.last) return { html: empty('Log a month so recommendations can be tailored to your usage.') };
    const l = d.last, sol = C.solar(avgKwh(d), state.settings), pts = C.points(state), lv = C.level(pts);
    const prof = M.classify(featFor(l)), recs = C.recommend(l.e, state.settings, sol), cm = thisMonth();
    const done = (id) => state.done.some((x) => x.id === id && x.month === cm);
    let html = '<section class="card"><h2>🌱 Eco Points</h2><div class="stat">' + fmt(pts) + ' <small>· ' + lv.name + '</small></div><div class="bar"><i style="width:' + Math.round(lv.progress * 100) + '%"></i></div>' +
      '<p class="muted small">' + (lv.next ? fmt(lv.toNext) + ' points to ' + lv.next : 'Top level reached!') + '. Earn +20 for logging a month, +30 when your footprint falls, plus points for each action.</p></section>' +
      '<section class="card"><h2>Your behaviour profile</h2><span class="tag">' + prof.name + '</span><p class="muted small">K-Means clustering compares your per-person electricity, transport and other emissions with three illustrative reference household groups.</p></section>' +
      '<h2 style="margin:6px 4px">Give Back to Nature</h2>';
    recs.forEach((r) => {
      html += '<section class="card"><div class="rec"><div class="ic">' + r.icon + '</div><div style="flex:1"><b>' + r.title + '</b><span class="muted small">' + r.why + '</span>' +
        '<div style="margin-top:6px"><span class="tag">' + (r.savingKg > 0 ? '≈ ' + fmt(r.savingKg, 1) + ' kg CO2e / mo' : 'Waste reduction') + '</span> <span class="tag">+' + r.points + ' pts</span>' + (r.savingInr > 0 ? ' <span class="tag">save ' + inr(r.savingInr) + '/mo</span>' : '') + '</div></div></div>' +
        (done(r.id) ? '<button class="btn sm ghost" data-act="undo" data-id="' + r.id + '">✓ Done this month (undo)</button>' : '<button class="btn sm" data-act="done" data-id="' + r.id + '" data-pts="' + r.points + '">Mark as done</button>') + '</section>';
    });
    return { html };
  }

  /* ---------------------------------------------------------------- ANALYTICS */
  function stats() {
    const d = derive(), s = state.settings;
    let html = '';
    if (d.last) {
      const kwh = d.rows.map((r) => C.n(r.e.electricityKwh)), fc = M.forecastNext(kwh);
      const series = C.CATS.map((c) => ({ name: c.label, color: c.color, values: d.rows.map((r) => r.fp[c.key]) }));
      const avgs = C.CATS.map((c) => ({ label: c.label, color: c.color, v: mean(d.rows.map((r) => r.fp[c.key])) })).sort((a, b) => b.v - a.v);
      html += '<section class="card"><h2>Footprint trend (kg CO2e)</h2><canvas id="cTrend"></canvas></section>' +
        '<section class="card"><h2>Breakdown by category</h2><canvas id="cStack"></canvas>' + legend(series.map((x) => ({ label: x.name, color: x.color }))) +
        '<p class="muted small">Largest average contributor: <b>' + avgs[0].label + '</b> (' + fmt(avgs[0].v) + ' kg a month).</p></section>' +
        '<section class="card"><h2>History</h2><table><tr><th>Month</th><th>Score</th><th>CO2e kg</th><th>kWh</th><th>Spend</th></tr>' +
        d.rows.slice().reverse().map((r) => '<tr><td>' + r.m + '</td><td>' + r.score + '</td><td>' + fmt(r.fp.total) + '</td><td>' + fmt(r.e.electricityKwh) + '</td><td>' + inr(r.spend.total) + '</td></tr>').join('') + '</table></section>' +
        '<section class="card"><h2>Model report</h2><div class="row"><span>Forecast model</span><b>' + fc.method + '</b></div><div class="row"><span>Months of data</span><b>' + fc.n + '</b></div>' +
        (fc.mae != null ? '<div class="row"><span>MAE / RMSE</span><b>' + fmt(fc.mae, 1) + ' / ' + fmt(fc.rmse, 1) + ' kWh</b></div>' : '<div class="row"><span>MAE / RMSE</span><b>needs 4+ months</b></div>') +
        '<div class="row"><span>Behaviour cluster</span><b>' + M.classify(featFor(d.last)).name + '</b></div></section>';
    } else html += empty('Charts, history and model metrics appear after you log data.');

    const r = s.rates;
    html += '<section class="card"><h2>⚙️ Settings</h2><form data-form="settings">' +
      '<label class="f"><span>Household members</span><div class="inp"><input type="number" min="1" step="1" name="members" value="' + s.members + '"></div></label>' +
      '<h3>Electricity tariff (₹ per unit)</h3><div class="grid">' +
      [['0 – 150 units', 0], ['151 – 300', 1], ['301 – 500', 2], ['Above 500', 3]].map((x) => '<label class="f"><span>' + x[0] + '</span><div class="inp"><input type="number" min="0" step="0.05" name="rate' + x[1] + '" value="' + r[x[1]] + '"></div></label>').join('') + '</div>' +
      '<h3>Solar assumptions</h3><label class="f"><span>Cost per kW</span><div class="inp"><input type="number" min="0" name="solarCostPerKw" value="' + s.solarCostPerKw + '"><em>₹</em></div></label>' +
      '<label class="f"><span>Yield per kW per day</span><div class="inp"><input type="number" min="0.5" step="0.1" name="solarYield" value="' + s.solarYield + '"><em>kWh</em></div></label>' +
      '<label class="f"><span>Subsidy</span><div class="inp"><input type="number" min="0" max="100" name="subsidyPct" value="' + s.subsidyPct + '"><em>%</em></div></label>' +
      '<button class="btn" type="submit">Save settings</button></form></section>' +
      '<section class="card"><h2>Your data</h2><p class="muted small" style="margin-top:0">Everything is stored only on this device.</p>' +
      '<button class="btn sm ghost" data-act="demo">Load demo data</button><button class="btn sm ghost" data-act="backup">Backup / restore</button><button class="btn sm danger" data-act="reset">Delete all data</button>' +
      (showBackup ? '<textarea id="bk" spellcheck="false">' + JSON.stringify(state).replace(/</g, '\\u003c') + '</textarea><button class="btn sm" data-act="copy">Copy</button><button class="btn sm ghost" data-act="import">Restore from text above</button>' : '') + '</section>';
    return { html, mount() {
      if (!d.last) return;
      Charts.line($('#cTrend'), d.ms, d.rows.map((x) => x.fp.total));
      Charts.stack($('#cStack'), d.ms, C.CATS.map((c) => ({ color: c.color, values: d.rows.map((x) => x.fp[c.key]) })));
    } };
  }

  const views = { home, impact, energy, money, give, stats };

  function render(top) {
    const v = views[tab]();
    $('#view').innerHTML = v.html;
    $('#nav').innerHTML = TABS.map((t) => '<button data-go="' + t[0] + '" class="' + (t[0] === tab ? 'on' : '') + '"><span>' + t[1] + '</span>' + t[2] + '</button>').join('');
    if (v.mount) { try { v.mount(); } catch (err) { console.error(err); } }
    if (top) window.scrollTo(0, 0);
  }

  /* ---------------------------------------------------------------- actions */
  function demoData() {
    const base = new Date(); const kwh = [340, 395, 430, 410, 360, 315];
    const entries = {};
    kwh.forEach((k, i) => {
      const dt = new Date(base.getFullYear(), base.getMonth() - (kwh.length - 1 - i), 1);
      const key = dt.getFullYear() + '-' + pad(dt.getMonth() + 1);
      entries[key] = { electricityKwh: k, waterL: 13500 + i * 300, carKm: 260 - i * 10, bikeKm: 120, busKm: 30 + i * 5, metroKm: 40 + i * 8, cycleKm: 20,
        diet: 'mixed', wasteKg: 38 - i, paperSheets: 180 - i * 10, costWater: 280, costTransport: 3200 - i * 80, costFood: 11000 + i * 150, costOther: 1500 };
    });
    state.entries = Object.assign({}, state.entries, entries); persist();
  }

  const acts = {
    demo() { demoData(); toast('Demo data loaded'); render(); },
    done(t) {
      state.done.push({ id: t.dataset.id, month: thisMonth(), points: Number(t.dataset.pts) || 0, ts: Date.now() });
      persist(); toast('+' + t.dataset.pts + ' Eco Points 🌳'); render();
    },
    undo(t) { state.done = state.done.filter((x) => !(x.id === t.dataset.id && x.month === thisMonth())); persist(); render(); },
    reset() { if (window.confirm('Delete all EcoBalance data on this device?')) { state = Store.fresh(); persist(); showBackup = false; toast('All data deleted'); render(true); } },
    backup() { showBackup = !showBackup; render(); },
    copy() { const t = $('#bk'); t.select(); try { navigator.clipboard.writeText(t.value); toast('Copied'); } catch (e) { document.execCommand('copy'); toast('Copied'); } },
    import() {
      try { state = Store.sanitize(JSON.parse($('#bk').value)); persist(); toast('Data restored'); render(); } catch (e) { toast('That text is not valid backup data'); }
    }
  };

  const forms = {
    entry(f) {
      const v = {}; new FormData(f).forEach((val, k) => { v[k] = val; });
      if (!v.month) { toast('Choose a month'); return; }
      const e = { diet: v.diet || 'mixed' };
      ['electricityKwh', 'waterL', 'carKm', 'bikeKm', 'busKm', 'metroKm', 'cycleKm', 'wasteKg', 'paperSheets', 'costElectricity', 'costWater', 'costTransport', 'costFood', 'costOther']
        .forEach((k) => { e[k] = C.n(v[k]); });
      state.entries[v.month] = e; formMonth = v.month; persist();
      const r = C.score(C.footprint(e, state.settings).total, state.settings.members);
      toast('Saved · Impact Score ' + r); render();
    },
    solar(f) { state.settings.solarKw = C.n(new FormData(f).get('solarKw')); persist(); toast('Solar plan updated'); render(); },
    settings(f) {
      const v = {}; new FormData(f).forEach((val, k) => { v[k] = C.n(val); });
      const s = state.settings;
      s.members = Math.max(1, Math.round(v.members) || 1);
      s.rates = [v.rate0, v.rate1, v.rate2, v.rate3].map((x, i) => x || C.DEFAULT_RATES[i]);
      s.solarCostPerKw = v.solarCostPerKw || C.DEFAULT_SETTINGS.solarCostPerKw;
      s.solarYield = v.solarYield || C.DEFAULT_SETTINGS.solarYield;
      s.subsidyPct = Math.min(100, v.subsidyPct);
      persist(); toast('Settings saved'); render();
    }
  };

  document.addEventListener('click', (ev) => {
    const t = ev.target.closest('[data-go],[data-act]'); if (!t) return;
    if (t.dataset.go) { tab = t.dataset.go; render(true); return; }
    if (acts[t.dataset.act]) acts[t.dataset.act](t);
  });
  document.addEventListener('change', (ev) => { if (ev.target.id === 'fmonth' && ev.target.value) { formMonth = ev.target.value; render(); } });
  document.addEventListener('submit', (ev) => { ev.preventDefault(); const f = ev.target; if (forms[f.dataset.form]) forms[f.dataset.form](f); });
  window.addEventListener('resize', () => { clearTimeout(window.__rz); window.__rz = setTimeout(() => render(), 200); });

  render(true);
  window.__eco = { render, getState: () => state, setTab: (t) => { tab = t; render(true); } };
})();
