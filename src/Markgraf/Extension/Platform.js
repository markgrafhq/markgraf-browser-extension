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
