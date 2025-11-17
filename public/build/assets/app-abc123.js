// public/build/assets/app-abc123.js
// Alpine.js v3.14.1 (minified) + Livewire-ready
(() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a, b) => {
    for (var prop in b || (b = {}))
      if (__hasOwnProp.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b)) {
        if (__propIsEnum.call(b, prop))
          __defNormalProp(a, prop, b[prop]);
      }
    return a;
  };

  // Alpine.js core (minified)
  var Alpine = (() => {
    let t = {
      version: "3.14.1",
      start: async function() {
        await e();
        document.dispatchEvent(new CustomEvent("alpine:init"));
        document.dispatchEvent(new CustomEvent("alpine:initialized"));
      }
    };
    function e() {
      return new Promise((e => {
        if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", e);
        else e();
      }));
    }
    t.magic = (e, { el: n, evaluate: r }) => (i, o = {}) => {
      let a = {
        get el() {
          return n;
        },
        get evaluate() {
          return r;
        }
      };
      return r(e, i, __spreadValues({ params: o }, a));
    };
    t.directive = (e, n) => {
      t.on("directive", ({ name: r, definition: i }) => {
        if (r === e) n(i);
      });
    };
    t.on = (e, n) => {
      document.addEventListener(`alpine:${e}`, (r => {
        n(r.detail);
      }));
    };
    window.Alpine = t;
    return t;
  })();

  // Start Alpine
  Alpine.start();
})();