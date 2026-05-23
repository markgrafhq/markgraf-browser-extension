// Zip the extension's runtime files into dist/markgraf-browser-extension-<version>.zip.
// Excludes node_modules, scripts, package.json, and .git — only what the
// stores need to install.
import { execFileSync } from "node:child_process";
import { readFileSync, mkdirSync, rmSync } from "node:fs";

const pkg = JSON.parse(readFileSync("package.json", "utf8"));
const out = `dist/markgraf-browser-extension-${pkg.version}.zip`;

mkdirSync("dist", { recursive: true });
rmSync(out, { force: true });

execFileSync("zip", [
  "-r", out,
  "manifest.json",
  "content.js",
  "extension.css",
  "assets",
], { stdio: "inherit" });

console.log(`packed ${out}`);
