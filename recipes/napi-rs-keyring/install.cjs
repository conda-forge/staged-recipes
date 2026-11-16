const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const pkg = path.join(process.env.PREFIX, "lib", "node_modules", "@napi-rs", "keyring");
fs.mkdirSync(pkg, { recursive: true });
for (const name of ["package.json", "index.js", "index.d.ts", "keytar.js", "keytar.d.ts", "LICENSE"]) {
  fs.copyFileSync(name, path.join(pkg, name));
}

const library = {
  darwin: "libnapi_keyring.dylib",
  linux: "libnapi_keyring.so",
  win32: "napi_keyring.dll",
}[process.platform];
const suffix = { darwin: "", linux: "-gnu", win32: "-msvc" }[process.platform];
const release = path.join("target", process.env.CARGO_BUILD_TARGET || "", "release");
const binding = `keyring.${process.platform}-${process.arch}${suffix}.node`;
const destination = path.join(pkg, binding);
fs.copyFileSync(path.join(release, library), destination);
if (process.platform === "darwin") {
  execFileSync("install_name_tool", ["-id", `@rpath/${binding}`, "-add_rpath", "@loader_path", destination]);
}
