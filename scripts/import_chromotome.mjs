#!/usr/bin/env node

/**
 * Collect chromotome palettes into a single JSON array.
 *
 * Usage:
 *   node scripts/import_chromotome.mjs [path-to-chromotome/palettes]
 *
 * Writes JSON to stdout; redirect to priv/palettes/chromotome.json.
 */

import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const palettesDir = path.resolve(
  process.argv[2] || path.join("..", "chromotome", "palettes")
);

function die(msg) {
  console.error(msg);
  process.exit(1);
}

if (!fs.existsSync(palettesDir)) {
  die(`Palettes directory not found: ${palettesDir}`);
}

const files = fs
  .readdirSync(palettesDir)
  .filter((f) => f.endsWith(".js"))
  .sort();

async function loadAll() {
  const all = [];

  for (const file of files) {
    const url = pathToFileURL(path.join(palettesDir, file)).href;
    const mod = await import(url);
    const items = mod.default || [];
    const source = path.basename(file, ".js");

    items.forEach((p) => {
      const palette = {
        ...p,
        source,
      };

      if (!palette.name) {
        palette.name = `${source}_${all.length}`;
      }

      all.push(palette);
    });
  }

  return all;
}

loadAll()
  .then((all) => {
    process.stdout.write(JSON.stringify(all, null, 2));
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
