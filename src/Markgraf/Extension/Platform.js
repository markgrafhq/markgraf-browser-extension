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
  el.closest("div.snippet-clipboard-content") ||
  el.closest("div.highlight, div[class*='highlight-source-']") ||
  el.closest("pre") ||
  el;

export const installSourceTogglesImpl = () => {
  document.querySelectorAll("[data-markgraf]").forEach((el) => {
    if (el.dataset.markgrafToggle === "1") return;
    el.dataset.markgrafToggle = "1";
    const pre = document.createElement("pre");
    pre.className = "markgraf-source";
    pre.textContent = el.getAttribute("data-markgraf-src") || "";
    el.appendChild(pre);
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "markgraf-source-toggle";
    btn.setAttribute("aria-label", "toggle source");
    btn.textContent = "</>";
    btn.addEventListener("click", () => {
      el.classList.toggle("markgraf-show-source");
    });
    el.appendChild(btn);
  });
};
