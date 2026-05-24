export const runtimeGetURLImpl = (path) => () => chrome.runtime.getURL(path);

export const queueMicrotaskImpl = (cb) => () => queueMicrotask(cb);

export const windowMarkgrafTryParseFnImpl = () =>
  (window.markgraf && window.markgraf.tryParse) || null;

export const windowMarkgrafMountAllFnImpl = () =>
  (window.markgraf && window.markgraf.mountAll) || null;

export const callTryParseImpl = (fn) => (src) => () => fn(src);

export const callMountAllImpl = (fn) => () => fn();

export const replaceWithImpl = (oldEl) => (newEl) => () => oldEl.replaceWith(newEl);

export const parseOkImpl = (result) => result.ok;

export const pauseAllEmbedsImpl = () => {
  document.querySelectorAll("[data-markgraf]").forEach((el) => {
    const btn = el.querySelector('[data-mg="play"]');
    if (btn && btn.dataset.mgPlaying === "1") btn.click();
  });
};

export const outerCodeContainerImpl = (el) => () =>
  el.closest("div.highlight, div[class*='highlight-source-']") ||
  el.closest("pre") ||
  el;
