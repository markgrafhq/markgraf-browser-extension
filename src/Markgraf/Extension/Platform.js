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

// Lazy-mount each [data-markgraf] when it scrolls into view, after the
// CommitMono font has loaded.  Until then the embed shows the source as a
// placeholder (markup added by Content.purs).  On mount we also pause the
// embed (the bundle's first-mount auto-plays otherwise) and install the
// </>-source-toggle button.
export const installLazyMountImpl = () => {
  const mountFn = window.markgraf && window.markgraf.mount;
  if (!mountFn) return;

  const fontReady =
    typeof document.fonts?.load === "function"
      ? document.fonts.load('12px "CommitMono"').catch(() => {})
      : Promise.resolve();

  const installToggle = (el) => {
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
    btn.innerHTML =
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.75" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5"/></svg>';
    btn.addEventListener("click", () =>
      el.classList.toggle("markgraf-show-source"),
    );
    el.appendChild(btn);
  };

  const mountOne = async (el) => {
    if (el.dataset.markgrafLazy !== "pending") return;
    el.dataset.markgrafLazy = "mounting";
    await fontReady;
    const src = el.getAttribute("data-markgraf-src") || "";
    mountFn(el, src);
    el.dataset.markgrafLazy = "done";
    const btn = el.querySelector('[data-mg="play"]');
    if (btn && btn.dataset.mgPlaying === "1") btn.click();
    installToggle(el);
  };

  const schedule = (el) => {
    if (typeof requestIdleCallback === "function") {
      requestIdleCallback(() => mountOne(el), { timeout: 250 });
    } else {
      setTimeout(() => mountOne(el), 0);
    }
  };

  const io = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          io.unobserve(entry.target);
          schedule(entry.target);
        }
      }
    },
    { rootMargin: "300px 0px" },
  );

  document
    .querySelectorAll("[data-markgraf-lazy='pending']")
    .forEach((el) => io.observe(el));
};
