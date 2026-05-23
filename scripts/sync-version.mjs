// Copy package.json's version into manifest.json so the two never drift.
// Run before packing the extension zip.
import { readFileSync, writeFileSync } from "node:fs";

const pkg = JSON.parse(readFileSync("package.json", "utf8"));
const manifest = JSON.parse(readFileSync("manifest.json", "utf8"));

if (manifest.version === pkg.version) {
  console.log(`manifest.json already at ${pkg.version}`);
} else {
  manifest.version = pkg.version;
  writeFileSync("manifest.json", JSON.stringify(manifest, null, 2) + "\n");
  console.log(`manifest.json -> ${pkg.version}`);
}
