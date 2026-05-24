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
    // heroicons/outline/code-bracket
    btn.innerHTML =
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.75" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5"/></svg>';
    btn.addEventListener("click", () => {
      el.classList.toggle("markgraf-show-source");
    });
    el.appendChild(btn);
  });
};
