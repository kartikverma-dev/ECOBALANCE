/* EcoBalance - machine learning module (runs on-device, no server needed).
   1) Linear regression forecast of next-month electricity use (+ MAE / RMSE validation)
   2) K-Means clustering of behaviour profiles against illustrative reference households */
(function (root) {
  'use strict';

  function linreg(y) {
    const n = y.length;
    let sx = 0, sy = 0, sxy = 0, sxx = 0;
    for (let i = 0; i < n; i++) { sx += i; sy += y[i]; sxy += i * y[i]; sxx += i * i; }
    const den = n * sxx - sx * sx;
    const slope = den === 0 ? 0 : (n * sxy - sx * sy) / den;
    const intercept = (sy - slope * sx) / n;
    const mean = sy / n;
    let ssRes = 0, ssTot = 0;
    for (let i = 0; i < n; i++) {
      ssRes += Math.pow(y[i] - (intercept + slope * i), 2);
      ssTot += Math.pow(y[i] - mean, 2);
    }
    return { slope, intercept, r2: ssTot === 0 ? 1 : 1 - ssRes / ssTot, rmse: Math.sqrt(ssRes / n) };
  }

  function forecastNext(y) {
    const n = y.length;
    if (n === 0) return null;
    if (n < 3) {
      const avg = y.reduce((a, b) => a + b, 0) / n;
      return { value: avg, method: 'Average of logged months', n, slope: 0, r2: null, mae: null, rmse: null, confidence: 'Low' };
    }
    const m = linreg(y);
    const value = Math.max(0, m.intercept + m.slope * n);
    let mae = null;
    if (n >= 4) { // leave-one-out validation
      let err = 0;
      for (let i = 0; i < n; i++) {
        const rest = y.filter((_, k) => k !== i);
        // refit on remaining points keeping their original time index
        const idx = rest.map((_, k) => (k < i ? k : k + 1));
        const mx = idx.reduce((a, b) => a + b, 0) / idx.length, my = rest.reduce((a, b) => a + b, 0) / rest.length;
        let num = 0, den = 0;
        idx.forEach((xv, k) => { num += (xv - mx) * (rest[k] - my); den += (xv - mx) * (xv - mx); });
        const sl = den === 0 ? 0 : num / den, ic = my - sl * mx;
        err += Math.abs(y[i] - (ic + sl * i));
      }
      mae = err / n;
    }
    return { value, method: 'Linear regression', n, slope: m.slope, r2: m.r2, mae, rmse: m.rmse,
      confidence: n >= 6 && m.r2 > 0.5 ? 'Good' : n >= 4 ? 'Medium' : 'Low' };
  }

  // ---- K-Means -----------------------------------------------------------------
  function mulberry32(a) {
    return function () {
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  function dist(a, b, sd) {
    let s = 0;
    for (let i = 0; i < a.length; i++) s += Math.pow((a[i] - b[i]) / sd[i], 2);
    return Math.sqrt(s);
  }

  function kmeans(pts, k, init, sd, iters) {
    let cents = init.map((c) => c.slice());
    let labels = new Array(pts.length).fill(0);
    for (let it = 0; it < (iters || 50); it++) {
      labels = pts.map((p) => {
        let best = 0, bd = Infinity;
        cents.forEach((c, i) => { const d = dist(p, c, sd); if (d < bd) { bd = d; best = i; } });
        return best;
      });
      const next = cents.map((c, i) => {
        const mem = pts.filter((_, j) => labels[j] === i);
        if (!mem.length) return c;
        return c.map((_, d) => mem.reduce((a, p) => a + p[d], 0) / mem.length);
      });
      const moved = next.some((c, i) => dist(c, cents[i], sd) > 1e-6);
      cents = next;
      if (!moved) break;
    }
    return { centroids: cents, labels };
  }

  // Features (kg CO2e per person per month): [electricity, transport, food+water+waste+paper]
  // Reference households are synthetic and only illustrate the technique.
  const NAMES = ['Eco Champion', 'Balanced Liver', 'High-Impact Household'];
  let model = null;

  function buildModel() {
    const rnd = mulberry32(42);
    const gauss = () => Math.sqrt(-2 * Math.log(rnd() + 1e-9)) * Math.cos(2 * Math.PI * rnd());
    const groups = [[22, 10, 70, 5, 6, 8], [42, 35, 95, 7, 9, 10], [75, 80, 140, 9, 12, 14]];
    const pts = [];
    groups.forEach((g) => { for (let i = 0; i < 40; i++) pts.push([0, 1, 2].map((d) => Math.max(1, g[d] + gauss() * g[d + 3]))); });
    const sd = [0, 1, 2].map((d) => {
      const m = pts.reduce((a, p) => a + p[d], 0) / pts.length;
      return Math.sqrt(pts.reduce((a, p) => a + Math.pow(p[d] - m, 2), 0) / pts.length) || 1;
    });
    const sorted = pts.slice().sort((a, b) => (a[0] + a[1] + a[2]) - (b[0] + b[1] + b[2]));
    const init = [sorted[0], sorted[Math.floor(sorted.length / 2)], sorted[sorted.length - 1]];
    const res = kmeans(pts, 3, init, sd);
    const order = res.centroids.map((c, i) => ({ c, i, t: c[0] + c[1] + c[2] })).sort((a, b) => a.t - b.t);
    return { centroids: order.map((o) => o.c), sd };
  }

  function classify(feat) {
    if (!model) model = buildModel();
    let best = 0, bd = Infinity;
    model.centroids.forEach((c, i) => { const d = dist(feat, c, model.sd); if (d < bd) { bd = d; best = i; } });
    return { index: best, name: NAMES[best], centroid: model.centroids[best].slice() };
  }

  const api = { linreg, forecastNext, kmeans, classify, NAMES };
  if (typeof module !== 'undefined' && module.exports) module.exports = api; else root.Ml = api;
})(typeof window !== 'undefined' ? window : globalThis);
