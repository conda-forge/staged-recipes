#!/usr/bin/env node
/*
 * Collect the full license text of every bundled production dependency in
 * node_modules and concatenate them into a single disclaimer file. conda-forge
 * requires the licenses of all code shipped inside the package (here, the
 * bundled node_modules tree) to be captured via about.license_file.
 *
 * This is the npm-equivalent of `pnpm-licenses generate-disclaimer`, written as
 * a self-contained node script so it needs no extra tooling or network access
 * at build time and behaves identically on Unix and Windows (noarch).
 */
"use strict";

const fs = require("fs");
const path = require("path");

const root = path.join(process.cwd(), "node_modules");
const outFile = path.join(process.cwd(), "THIRD_PARTY_LICENSES.txt");

const LICENSE_RE = /^(LICEN[CS]E|COPYING|NOTICE|UNLICENSE)/i;

// Walk node_modules and yield every package directory (handles scoped @org/pkg
// packages and nested node_modules).
function* packageDirs(dir) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    if (!entry.isDirectory() && !entry.isSymbolicLink()) continue;
    const name = entry.name;
    if (name === ".bin") continue;
    const full = path.join(dir, name);
    if (name.startsWith("@")) {
      // Scope directory: recurse one level into the scoped packages.
      yield* packageDirs(full);
      continue;
    }
    if (fs.existsSync(path.join(full, "package.json"))) {
      yield full;
    }
    const nested = path.join(full, "node_modules");
    if (fs.existsSync(nested)) {
      yield* packageDirs(nested);
    }
  }
}

function findLicenseFile(pkgDir) {
  let files;
  try {
    files = fs.readdirSync(pkgDir);
  } catch {
    return null;
  }
  const match = files.find((f) => LICENSE_RE.test(f));
  return match ? path.join(pkgDir, match) : null;
}

if (!fs.existsSync(root)) {
  // No bundled dependencies; still emit a header so license_file resolves.
  fs.writeFileSync(outFile, "No bundled third-party dependencies.\n");
  process.exit(0);
}

const seen = new Set();
const blocks = [];

for (const pkgDir of packageDirs(root)) {
  let meta;
  try {
    meta = JSON.parse(fs.readFileSync(path.join(pkgDir, "package.json"), "utf8"));
  } catch {
    continue;
  }
  const id = `${meta.name}@${meta.version}`;
  if (seen.has(id)) continue;
  seen.add(id);

  const declared =
    typeof meta.license === "string"
      ? meta.license
      : (meta.license && meta.license.type) ||
        (Array.isArray(meta.licenses) &&
          meta.licenses.map((l) => l.type).join(" OR ")) ||
        "UNKNOWN";

  const licenseFile = findLicenseFile(pkgDir);
  const text = licenseFile
    ? fs.readFileSync(licenseFile, "utf8").trim()
    : `(No license file bundled; declared license: ${declared})`;

  blocks.push(
    `================================================================================\n` +
      `Package: ${id}\n` +
      `License: ${declared}\n` +
      `================================================================================\n\n` +
      `${text}\n`
  );
}

blocks.sort();

const header =
  "THIRD-PARTY SOFTWARE LICENSES\n" +
  "This package bundles the following production dependencies in node_modules.\n" +
  `Total: ${blocks.length} package(s).\n\n`;

fs.writeFileSync(outFile, header + blocks.join("\n"));
process.stdout.write(`Wrote ${outFile} (${blocks.length} packages)\n`);
