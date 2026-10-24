const assert = require('assert');
const C = require('../www/js/calc.js');
const M = require('../www/js/ml.js');

// Slab bill: 150*5.5 + 150*6 + 100*6.5 = 825 + 900 + 650 = 2375
assert.strictEqual(C.billFor(400), 2375);
assert.strictEqual(C.billFor(0), 0);

// Footprint: 100 kWh * 0.82 = 82; 100 km car * 0.192 = 19.2
const fp = C.footprint({ electricityKwh: 100, carKm: 100, diet: 'vegetarian' }, { members: 2 });
assert.ok(Math.abs(fp.electricity - 82) < 1e-9);
assert.ok(Math.abs(fp.transport - 19.2) < 1e-9);
assert.strictEqual(fp.food, 200);

// Score bounds and monotonic
assert.strictEqual(C.score(0, 3), 100);
assert.strictEqual(C.score(5000, 3), 0);
assert.strictEqual(C.score(480, 3), 50);
assert.ok(C.score(300, 3) > C.score(600, 3));

// Solar
const s = C.solar(300, { solarKw: 0 });
assert.strictEqual(s.kw, 2.5);
assert.ok(s.monthlySaving > 0 && s.payback > 0 && s.payback < 30);
assert.strictEqual(C.solar(0), null);

// Regression: perfect line 100,110,120,130 -> next 140
const f = M.forecastNext([100, 110, 120, 130]);
assert.ok(Math.abs(f.value - 140) < 1e-9);
assert.ok(f.r2 > 0.999 && f.mae < 1e-6);
assert.strictEqual(M.forecastNext([]), null);
assert.strictEqual(M.forecastNext([50, 70]).value, 60);
assert.ok(M.forecastNext([100, 90, 80, 70, 60]).value >= 0);

// Clustering orders low -> high
const lo = M.classify([15, 8, 65]), hi = M.classify([85, 90, 150]);
assert.strictEqual(lo.index, 0);
assert.strictEqual(hi.index, 2);

// Recommendations & points
const recs = C.recommend({ electricityKwh: 450, carKm: 300, diet: 'nonveg', wasteKg: 40, paperSheets: 300, waterL: 20000 }, { members: 3 }, s);
assert.ok(recs.length >= 6 && recs.some((r) => r.id === 'tree'));
const st = { settings: C.DEFAULT_SETTINGS, entries: { '2026-08': { electricityKwh: 300 }, '2026-09': { electricityKwh: 200 } }, done: [{ points: 25 }] };
assert.strictEqual(C.points(st), 2 * 20 + 30 + 25);
assert.strictEqual(C.level(650).name, 'Tree');

console.log('All tests passed');
