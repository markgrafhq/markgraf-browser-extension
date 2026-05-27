---
title: Privacy Policy — Markgraf for GitHub
permalink: /privacy
---

# Privacy Policy

**Markgraf for GitHub** (the "extension") is designed to run entirely in your browser. This document explains what it does and does not do with your data.

## Data collection

The extension collects **no data**. It does not transmit anything off the page on which it runs.

## Network requests

The extension makes **no network requests**. The renderer that turns ```markgraf fenced code blocks into animations is bundled with the extension and runs from your local copy. Nothing is fetched from a server at runtime.

## Cookies and storage

The extension uses **no cookies** and writes **nothing** to browser storage (`localStorage`, `sessionStorage`, `chrome.storage`, IndexedDB, etc.).

## Permissions

The extension requests host access to `https://github.com/*` and `https://gist.github.com/*`. This access exists solely so the extension's content script can find ```markgraf fenced code blocks in pages you are already viewing and replace them with the inline animation player. Page contents are read in-memory and never transmitted.

## Third parties

The extension does not include any third-party analytics, advertising, tracking, telemetry, or error-reporting services.

## Source

The extension is open source under the MIT licence. The full source — including the manifest, content script, and bundled renderer — is published at <https://github.com/markgrafhq/markgraf-browser-extension>.

## Contact

Questions or concerns: open an issue at <https://github.com/markgrafhq/markgraf-browser-extension/issues>.

---

*Last updated: 2026-05-27.*
