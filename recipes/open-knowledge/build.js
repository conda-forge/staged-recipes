const fs = require("node:fs");
const path = require("node:path");

const prefix = process.env.PREFIX;
const root = process.platform === "win32" ? prefix : path.join(prefix, "lib");
const pkg = path.join(root, "node_modules", "@inkeep", "open-knowledge");

// The tarball ships prebuilt bindings for every platform, keep only ours.
const keep = {
  darwin: {
    arm64: "native-config.darwin-arm64.node",
    x64: "native-config.darwin-x64.node",
  },
  linux: {
    arm64: "native-config.linux-arm64-gnu.node",
    x64: "native-config.linux-x64-gnu.node",
  },
  win32: {
    arm64: "native-config.win32-arm64-msvc.node",
    x64: "native-config.win32-x64-msvc.node",
  },
}[process.platform][process.arch];

const native = path.join(pkg, "dist", "native");
for (const file of fs.readdirSync(native)) {
  if (file.endsWith(".node") && file !== keep) {
    fs.rmSync(path.join(native, file));
  }
}

// npm writes its Windows shims into the install prefix, not %PREFIX%\bin.
if (process.platform === "win32") {
  const bin = path.join(prefix, "bin");
  const cli = path.join(
    "%CONDA_PREFIX%",
    "node_modules",
    "@inkeep",
    "open-knowledge",
    "dist",
    "cli.mjs",
  );
  const body = `@echo off\r\n"%CONDA_PREFIX%\\node.exe" "${cli}" %*\r\n`;
  fs.mkdirSync(bin, { recursive: true });
  for (const name of ["ok", "open-knowledge"]) {
    fs.writeFileSync(path.join(bin, `${name}.cmd`), body);
  }
}
