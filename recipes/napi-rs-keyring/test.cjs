const assert = require("node:assert/strict");
const path = require("node:path");

const pkg = path.join(process.env.PREFIX, "lib", "node_modules", "@napi-rs", "keyring");
const { Entry, AsyncEntry } = require(pkg);
for (const entry of [Entry, AsyncEntry]) {
  assert.equal(typeof entry, "function");
  assert.equal(typeof entry.prototype.getPassword, "function");
  assert.equal(typeof entry.prototype.setPassword, "function");
}
assert.equal(typeof require(path.join(pkg, "keytar.js")).getPassword, "function");
