// Finds rendered ```markgraf fenced blocks in GitHub's markdown surfaces
// and swaps each for a <div data-markgraf> the embed bundle will mount.
//
// The embed bundle (assets/markgraf-embed.js) is listed as a sibling
// content script and auto-mounts on DOMContentLoaded — by document_idle
// it's already past that, so its else-branch fires synchronously and
// picks up the divs we created just above. PJAX navigations are handled
// by re-running transform + mountAll on DOM mutations.

// The embed CSS ships an @font-face with a relative url() which, when
// injected as a content-script stylesheet, resolves against the *page*
// origin (github.com) and trips GitHub's font-src CSP. Install the
// @font-face from here using chrome.runtime.getURL — an absolute
// chrome-extension:// URL is permitted by GitHub's CSP because
// extensions are exempt from page CSP for resources they fetch.
const installFontFace = () => {
  if (document.getElementById("markgraf-fontface")) return;
  const style = document.createElement("style");
  style.id = "markgraf-fontface";
  const url = chrome.runtime.getURL("assets/CommitMono-Regular.woff2");
  style.textContent = `@font-face{font-family:'CommitMono';src:url('${url}') format('woff2');font-weight:400;font-display:swap;}`;
  (document.head || document.documentElement).appendChild(style);
};
installFontFace();

// GitHub drops the language hint for unknown languages — for ```markgraf
// fences the rendered DOM is just `<pre class="notranslate"><code>…`
// with no attribute we can match on. So we detect by *content*:
// markgraf sources reliably begin with `seed`, `frame`, `par`, `seq`,
// or a node/edge mutation. Anchored at line start, this is distinctive
// enough to avoid false positives against shell/python/json blocks.
const MARKGRAF_SHAPE = /^\s*(seed\s+\d|frame\b|par\s*\{|seq\s*\{|[+-]node\b|[+-]edge\b)/m;

// Surfaces that contain rendered markdown on GitHub.
const CONTAINERS = ".markdown-body, .comment-body";

const sourceOf = (codeOrPre) => {
  const code = codeOrPre.tagName === "PRE"
    ? codeOrPre.querySelector("code") || codeOrPre
    : codeOrPre;
  return code.textContent || "";
};

// Cheap textual filter — keeps the parser off ~all non-markgraf blocks.
const looksLikeMarkgraf = (src) => MARKGRAF_SHAPE.test(src);

// True confirmation — feed the candidate to the actual markgraf parser
// exposed by the embed bundle. If it parses, it's markgraf.
const parsesAsMarkgraf = (src) => {
  const fn = window.markgraf?.tryParse;
  if (!fn) return true; // bundle not loaded yet; trust the regex this pass
  try { return fn(src).ok; } catch { return false; }
};

const transform = (root) => {
  let changed = false;
  const pres = root.querySelectorAll(`${CONTAINERS} pre`);
  for (const pre of pres) {
    if (pre.dataset.markgrafReplaced === "1") continue;
    const src = sourceOf(pre);
    if (!src.trim() || !looksLikeMarkgraf(src) || !parsesAsMarkgraf(src)) continue;
    const div = document.createElement("div");
    div.className = "markgraf-embed markgraf-gh";
    div.setAttribute("data-markgraf", "");
    div.dataset.markgrafReplaced = "1";
    div.textContent = src;
    pre.replaceWith(div);
    changed = true;
  }
  return changed;
};

const mountPending = () => {
  // window.markgraf is set by the embed bundle running in the same
  // isolated world. On the first pass it may not exist yet because the
  // bundle script is queued after this one — its DOMContentLoaded-else
  // branch will pick up the divs synchronously when it runs.
  if (window.markgraf?.mountAll) window.markgraf.mountAll();
};

transform(document);
mountPending();

// GitHub navigates via Turbo/PJAX without a full reload. Re-scan on any
// DOM addition; debounce via microtask so a burst of mutations triggers
// a single transform + mount pass.
let scheduled = false;
const schedule = () => {
  if (scheduled) return;
  scheduled = true;
  queueMicrotask(() => {
    scheduled = false;
    if (transform(document)) mountPending();
  });
};

new MutationObserver((records) => {
  for (const r of records) {
    if (r.addedNodes.length) { schedule(); return; }
  }
}).observe(document.body, { childList: true, subtree: true });
