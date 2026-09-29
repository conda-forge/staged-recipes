const fs = require("node:fs");
const path = require("node:path");

const prefix = process.env.PREFIX;
const parts = ["lib", "node_modules", "@inkeep", "open-knowledge"];
const pkg = path.join(prefix, ...parts);

// The name dist/native/index.js requires for this platform.
const binding = {
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

const built = {
  darwin: "libopen_knowledge_native_config.dylib",
  linux: "libopen_knowledge_native_config.so",
  win32: "open_knowledge_native_config.dll",
}[process.platform];

// conda-forge's rust sets CARGO_BUILD_TARGET, which nests the artifacts a
// level deeper than a plain `cargo build`.
const target = process.env.CARGO_BUILD_TARGET;
const release = path.join(
  process.env.SRC_DIR,
  "repo",
  "packages",
  "native-config",
  "target",
  ...(target ? [target] : []),
  "release",
);

// Drop every binding upstream prebuilt and install the one we compiled.
const native = path.join(pkg, "dist", "native");
for (const file of fs.readdirSync(native)) {
  if (file.endsWith(".node")) {
    fs.rmSync(path.join(native, file));
  }
}
fs.copyFileSync(path.join(release, built), path.join(native, binding));

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
