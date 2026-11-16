const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { createRequire } = require("node:module");

const modules = path.join(process.env.PREFIX, "lib", "node_modules");
const pkg = path.join(modules, "@inkeep", "open-knowledge");
const fromApp = createRequire(path.join(pkg, "package.json"));
for (const name of ["@napi-rs/keyring", "@parcel/watcher"]) {
  assert.equal(fromApp.resolve(name), path.join(modules, name, "index.js"));
  fromApp(name);
}

const native = fromApp("./dist/native/index.js");
assert.deepEqual(JSON.parse(native.parseTomlToJson("value = 42\n")), { value: 42 });

const binaries = fs.readdirSync(pkg, { recursive: true }).filter(name => name.endsWith(".node"));
assert.equal(binaries.length, 1, JSON.stringify(binaries));
assert.equal(path.dirname(binaries[0]), path.join("dist", "native"));
