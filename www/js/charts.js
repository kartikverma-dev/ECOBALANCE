/* EcoBalance - tiny dependency-free canvas charts (works fully offline). */
(function (root) {
  'use strict';
  const INK = '#33443a', GRID = '#e3ece5', GREEN = '#2e9e5b';

  function setup(c) {
    const dpr = root.devicePixelRatio || 1;
    const w = c.clientWidth || 300, h = c.clientHeight || 180;
    c.width = Math.round(w * dpr); c.height = Math.round(h * dpr);
    const g = c.getContext && c.getContext('2d');
    if (!g) return null;
    g.scale(dpr, dpr); g.clearRect(0, 0, w, h);
    g.font = '11px system-ui, sans-serif';
    return { g, w, h };
  }

  function niceMax(v) {
    if (v <= 0) return 1;
    const p = Math.pow(10, Math.floor(Math.log10(v))), f = v / p;
    return (f <= 1 ? 1 : f <= 2 ? 2 : f <= 5 ? 5 : 10) * p;
  }

  function frame(ctx, max, L, T, B) {
    const { g, w, h } = ctx;
    g.strokeStyle = GRID; g.fillStyle = '#6b7c70'; g.lineWidth = 1; g.textAlign = 'right';
    for (let i = 0; i <= 4; i++) {
      const y = T + (h - T - B) * (1 - i / 4);
      g.beginPath(); g.moveTo(L, y); g.lineTo(w - 6, y); g.stroke();
      g.fillText(String(Math.round((max * i) / 4)), L - 5, y + 4);
    }
  }

  function label(ms) {
    const [y, m] = ms.split('-').map(Number);
    return new Date(y, m - 1, 1).toLocaleString('en', { month: 'short' });
  }

  function bar(c, labels, values, opt) {
    opt = opt || {};
    const ctx = setup(c); if (!ctx) return;
    const { g, w, h } = ctx, L = 38, T = 12, B = 22;
    const all = values.concat(opt.forecast != null ? [opt.forecast] : []);
    const max = niceMax(Math.max.apply(null, all.concat([1])));
    frame(ctx, max, L, T, B);
    const cnt = all.length, slot = (w - L - 8) / cnt, bw = Math.min(34, slot * 0.6);
    all.forEach((v, i) => {
      const isF = i >= values.length, x = L + slot * i + (slot - bw) / 2, bh = (h - T - B) * (v / max);
      g.fillStyle = isF ? '#b9e0c6' : (opt.color || GREEN);
      g.fillRect(x, h - B - bh, bw, bh);
      if (isF) { g.strokeStyle = GREEN; g.setLineDash([4, 3]); g.strokeRect(x, h - B - bh, bw, bh); g.setLineDash([]); }
      g.fillStyle = INK; g.textAlign = 'center';
      g.fillText(isF ? 'Next' : label(labels[i]), x + bw / 2, h - 7);
      if (cnt <= 8) g.fillText(String(Math.round(v)), x + bw / 2, h - B - bh - 4);
    });
  }

  function line(c, labels, values, opt) {
    opt = opt || {};
    const ctx = setup(c); if (!ctx) return;
    const { g, w, h } = ctx, L = 38, T = 12, B = 22;
    const max = niceMax(Math.max.apply(null, values.concat([1])));
    frame(ctx, max, L, T, B);
    const slot = (w - L - 14) / Math.max(1, values.length - 1 || 1);
    const pt = (i, v) => [L + 6 + (values.length === 1 ? (w - L - 14) / 2 : slot * i), h - B - (h - T - B) * (v / max)];
    g.strokeStyle = opt.color || GREEN; g.lineWidth = 2.5; g.beginPath();
    values.forEach((v, i) => { const p = pt(i, v); i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]); });
    g.stroke();
    values.forEach((v, i) => {
      const p = pt(i, v);
      g.fillStyle = '#fff'; g.beginPath(); g.arc(p[0], p[1], 4, 0, 7); g.fill(); g.stroke();
      g.fillStyle = INK; g.textAlign = 'center'; g.fillText(label(labels[i]), p[0], h - 7);
    });
  }

  function stack(c, labels, series) {
    const ctx = setup(c); if (!ctx) return;
    const { g, w, h } = ctx, L = 38, T = 12, B = 22;
    const totals = labels.map((_, i) => series.reduce((a, s) => a + s.values[i], 0));
    const max = niceMax(Math.max.apply(null, totals.concat([1])));
    frame(ctx, max, L, T, B);
    const slot = (w - L - 8) / labels.length, bw = Math.min(34, slot * 0.6);
    labels.forEach((m, i) => {
      let y = h - B; const x = L + slot * i + (slot - bw) / 2;
      series.forEach((s) => {
        const bh = (h - T - B) * (s.values[i] / max);
        g.fillStyle = s.color; g.fillRect(x, y - bh, bw, bh); y -= bh;
      });
      g.fillStyle = INK; g.textAlign = 'center'; g.fillText(label(m), x + bw / 2, h - 7);
    });
  }

  function donut(c, parts, centre) {
    const ctx = setup(c); if (!ctx) return;
    const { g, w, h } = ctx, cx = w / 2, cy = h / 2, r = Math.min(w, h) / 2 - 6, total = parts.reduce((a, p) => a + p.value, 0);
    if (total <= 0) return;
    let a0 = -Math.PI / 2;
    parts.forEach((p) => {
      const a1 = a0 + (p.value / total) * Math.PI * 2;
      g.fillStyle = p.color; g.beginPath(); g.moveTo(cx, cy); g.arc(cx, cy, r, a0, a1); g.fill(); a0 = a1;
    });
    g.fillStyle = '#fff'; g.beginPath(); g.arc(cx, cy, r * 0.6, 0, 7); g.fill();
    g.fillStyle = INK; g.textAlign = 'center'; g.font = 'bold 16px system-ui, sans-serif';
    g.fillText(centre || '', cx, cy + 2);
    g.font = '11px system-ui, sans-serif'; g.fillStyle = '#6b7c70'; g.fillText('kg CO2e', cx, cy + 17);
  }

  root.Charts = { bar, line, stack, donut };
})(window);
