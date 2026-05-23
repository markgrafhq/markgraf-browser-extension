# markgraf-browser-extension

Browser extension that finds ```` ```markgraf ```` fenced code blocks on rendered markdown pages and replaces them with the live [markgraf](https://github.com/markgrafhq/markgraf) animation player.

Currently activates on github.com and gist.github.com; more surfaces (Notion, Reddit, Hacker News, etc.) can be added by extending `manifest.json`'s `content_scripts[].matches`.

## Demo

If the block below shows source code instead of a playable animation, you don't have the extension installed — install it (see below) and reload this page.

```markgraf
seed 1

frame setup {
  +node client "Client"
  +node api    "API"
  +node db     "Database"
  +node cache  "Cache"
  +edge client api
  +edge api db
  +edge api cache
}

frame "write request" {
  client -> api "POST /user"
  api -> db "INSERT"
}

frame "invalidate cache" {
  api -> cache "DEL user:42"
}

frame "respond" {
  client <- api "201"
}
```

## Install

- **Chrome / Brave / Opera / Vivaldi / Arc**: Chrome Web Store *(pending)*
- **Firefox**: addons.mozilla.org *(pending)*
- **Edge**: Edge Add-ons *(pending)*
- **Any Chromium**: download the latest zip from [Releases](https://github.com/markgrafhq/markgraf-browser-extension/releases), unzip, open `chrome://extensions`, enable Developer Mode, click "Load unpacked", pick the unzipped directory.

## Develop

```sh
bun install
bun run build       # pulls in @markgrafhq/markgraf-embed and syncs into assets/
```

Then in Chrome: `chrome://extensions` → Developer Mode → Load unpacked → pick this directory.

To pack a distributable zip:

```sh
bun run pack        # writes dist/markgraf-browser-extension-<version>.zip
```

## Release

1. Bump `version` in `package.json` (this becomes the manifest version too — `scripts/src/SyncVersion.purs` mirrors it before packing).
2. `git tag v0.x.y && git push --tags`.
3. Create a GitHub Release on that tag. `release.yml` builds the zip, attaches it to the release, and pushes to whichever stores have their secrets configured (jobs without secrets are skipped, not failed).

### Required secrets / variables

Set as **Variables** (non-sensitive, public-by-design):

| Variable | Purpose |
|---|---|
| `CHROME_EXTENSION_ID` | Item ID from your Chrome Web Store listing |
| `FIREFOX_EXTENSION_ID` | Add-on slug or GUID from AMO (used as a presence gate) |
| `EDGE_PRODUCT_ID` | Product ID from Edge Partner Center |

Set as **Secrets** (sensitive):

| Secret | How to get it |
|---|---|
| `CHROME_CLIENT_ID` / `CHROME_CLIENT_SECRET` / `CHROME_REFRESH_TOKEN` | [Chrome Web Store API guide](https://developer.chrome.com/docs/webstore/using-api) |
| `AMO_JWT_ISSUER` / `AMO_JWT_SECRET` | https://addons.mozilla.org/developers/addon/api/key/ |
| `EDGE_API_KEY` / `EDGE_CLIENT_ID` | Partner Center → Edge → API publishing settings |

Until a store's variables/secrets are set, its publish job is skipped — the release still happens with the zip attached for manual upload.
