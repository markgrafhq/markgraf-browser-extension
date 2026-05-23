// Copy the @markgrafhq/markgraf-embed bundle into assets/ for the extension
// to ship. The CSS @font-face is stripped here because its relative url()
// would resolve against the page origin at runtime (github.com etc.) and
// trip the page's font-src CSP — content.js installs a replacement
// @font-face that points at chrome.runtime.getURL(), which CSP permits.
import { copyFileSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";

const src = "node_modules/@markgrafhq/markgraf-embed/dist";
const dst = "assets";
mkdirSync(dst, { recursive: true });

copyFileSync(`${src}/markgraf-embed.js`, `${dst}/markgraf-embed.js`);

const css = readFileSync(`${src}/markgraf-embed.css`, "utf8");
const stripped = css.replace(/@font-face\s*\{[^}]*\}\s*/, "");
writeFileSync(`${dst}/markgraf-embed.css`, stripped);

console.log("synced markgraf-embed.{js,css} (font-face stripped)");
