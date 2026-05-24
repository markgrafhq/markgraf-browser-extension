export const runtimeGetURLImpl = (path) => () => chrome.runtime.getURL(path);

export const queueMicrotaskImpl = (cb) => () => queueMicrotask(cb);

export const windowMarkgrafTryParseFnImpl = () =>
  (window.markgraf && window.markgraf.tryParse) || null;

export const callTryParseImpl = (fn) => (src) => () => fn(src);

export const replaceWithImpl = (oldEl) => (newEl) => () => oldEl.replaceWith(newEl);

export const parseOkImpl = (result) => result.ok;

export const outerCodeContainerImpl = (el) => () =>
  el.closest("div.snippet-clipboard-content") ||
  el.closest("div.highlight, div[class*='highlight-source-']") ||
  el.closest("pre") ||
  el;

export const mountEmbedImpl = (el) => (src) => () => {
  const fn = window.markgraf && window.markgraf.mount;
  if (fn) fn(el, src);
};

export const newViewportObserverImpl = (rootMarginPx) => (cb) => () => {
  return new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) cb(entry.target)();
      }
    },
    { rootMargin: rootMarginPx + "px 0px" },
  );
};

export const observeElementImpl = (io) => (el) => () => io.observe(el);
export const unobserveElementImpl = (io) => (el) => () => io.unobserve(el);

export const requestIdleImpl = (cb) => () => {
  if (typeof requestIdleCallback === "function") {
    requestIdleCallback(() => cb(), { timeout: 250 });
  } else {
    setTimeout(() => cb(), 0);
  }
};

export const loadFontThenImpl = (fontSpec) => (cb) => () => {
  const done = () => cb()();
  if (typeof document.fonts?.load === "function") {
    document.fonts.load(fontSpec).then(done, done);
  } else {
    done();
  }
};

export const clickElementImpl = (el) => () => el.click();

export const classListToggleImpl = (cls) => (el) => () =>
  el.classList.toggle(cls);

export const setInnerHTMLImpl = (html) => (el) => () => {
  el.innerHTML = html;
};

export const addClickListenerImpl = (el) => (cb) => () =>
  el.addEventListener("click", () => cb());
