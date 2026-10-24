/* EcoBalance - on-device storage (localStorage inside the Android WebView). */
(function (root) {
  'use strict';
  const KEY = 'ecobalance.v1';

  function fresh() {
    return { settings: JSON.parse(JSON.stringify(root.Calc.DEFAULT_SETTINGS)), entries: {}, done: [] };
  }

  function sanitize(obj) {
    const base = fresh();
    if (!obj || typeof obj !== 'object') return base;
    const s = Object.assign({}, base.settings, obj.settings || {});
    if (!Array.isArray(s.rates) || s.rates.length !== 4) s.rates = base.settings.rates;
    return {
      settings: s,
      entries: obj.entries && typeof obj.entries === 'object' ? obj.entries : {},
      done: Array.isArray(obj.done) ? obj.done : []
    };
  }

  function load() {
    try { return sanitize(JSON.parse(root.localStorage.getItem(KEY))); } catch (e) { return fresh(); }
  }
  function save(state) {
    try { root.localStorage.setItem(KEY, JSON.stringify(state)); return true; } catch (e) { return false; }
  }

  root.Store = { load, save, fresh, sanitize };
})(window);
