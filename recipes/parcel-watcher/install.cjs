const fs = require("node:fs");
const path = require("node:path");

const pkg = path.join(process.env.PREFIX, "lib", "node_modules", "@parcel", "watcher");
fs.mkdirSync(path.join(pkg, "build", "Release"), { recursive: true });
for (const name of ["package.json", "index.js", "index.d.ts", "index.js.flow", "wrapper.js", "LICENSE", "node_modules"]) {
  fs.cpSync(name, path.join(pkg, name), { recursive: true });
}
fs.copyFileSync("build/Release/watcher.node", path.join(pkg, "build", "Release", "watcher.node"));
