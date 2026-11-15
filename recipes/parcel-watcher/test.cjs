const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { setTimeout: delay } = require("node:timers/promises");

const pkg = path.join(process.env.PREFIX, "lib", "node_modules", "@parcel", "watcher");
const watcher = require(pkg);
const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "parcel-watcher-")));

async function test() {
  const dir = path.join(root, "watched");
  fs.mkdirSync(dir);
  const snapshot = path.join(root, "snapshot");
  await watcher.writeSnapshot(dir, snapshot);
  const file = path.join(dir, "example.txt");
  fs.writeFileSync(file, "conda-forge");
  // FSEvents delivers changes asynchronously.
  const deadline = Date.now() + 10000;
  let events;
  do {
    events = await watcher.getEventsSince(dir, snapshot);
    if (events.some(event => event.path === file && event.type === "create")) return;
    await delay(20);
  } while (Date.now() < deadline);
  assert.fail(`Timed out waiting for file creation: ${JSON.stringify(events)}`);
}

test().finally(() => fs.rmSync(root, { recursive: true, force: true }));
