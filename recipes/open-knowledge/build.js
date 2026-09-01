const fs = require("node:fs");
const path = require("node:path");

const prefix = process.env.PREFIX;
const parts = ["lib", "node_modules", "@inkeep", "open-knowledge"];
const pkg = path.join(prefix, ...parts);

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

// npm puts its Windows shims next to the install prefix, not in %PREFIX%\bin.
if (process.platform === "win32") {
  const bin = path.join(prefix, "bin");
  const cli = path.join("%CONDA_PREFIX%", ...parts, "dist", "cli.mjs");
  const body = `@echo off\r\n"%CONDA_PREFIX%\\node.exe" "${cli}" %*\r\n`;
  fs.mkdirSync(bin, { recursive: true });
  for (const name of ["ok", "open-knowledge"]) {
    fs.writeFileSync(path.join(bin, `${name}.cmd`), body);
  }
}
