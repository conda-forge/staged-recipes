// Concatenate license files of every installed package in a node_modules tree.
const fs = require('fs');
const path = require('path');
const root = process.argv[2];
const seen = new Set();
function walk(dir) {
  for (const name of fs.readdirSync(dir).sort()) {
    if (name.startsWith('.')) continue;
    const p = path.join(dir, name);
    if (name.startsWith('@')) { walk(p); continue; }
    const pj = path.join(p, 'package.json');
    if (!fs.existsSync(pj)) continue;
    const pkg = JSON.parse(fs.readFileSync(pj, 'utf8'));
    const id = `${pkg.name}@${pkg.version}`;
    if (!seen.has(id)) {
      seen.add(id);
      const lic = fs.readdirSync(p).filter(f => /^(licen[cs]e|copying|notice)/i.test(f));
      process.stdout.write(`\n==== ${id} (${JSON.stringify(pkg.license || pkg.licenses || 'UNKNOWN')}) ====\n`);
      for (const f of lic) {
        const fp = path.join(p, f);
        if (fs.statSync(fp).isFile()) process.stdout.write(fs.readFileSync(fp, 'utf8') + '\n');
      }
    }
    const nm = path.join(p, 'node_modules');
    if (fs.existsSync(nm)) walk(nm);
  }
}
walk(root);
