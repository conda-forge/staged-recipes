// Helper for build.sh, run with bun from the ovis source root.
//
//   bun collect-node-modules.ts <out-node-modules> <licenses-file> <shipped source dir>...
//
// 1. Copies the transitive closure of the npm packages imported by the shipped TypeScript sources
//    into <out-node-modules>. The client's dependencies are bundled into dist/ by vite, so only the
//    server's are needed.
// 2. Writes the license texts of every package shipped in the conda package (that closure plus the
//    client's bundled `dependencies` closure) into <licenses-file>.
import { cpSync, existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const [outDir, licensesFile, ...sourceDirs] = process.argv.slice(2);
if (!outDir || !licensesFile || sourceDirs.length === 0) {
  throw new Error("usage: bun collect-node-modules.ts <out-node-modules> <licenses-file> <shipped source dir>...");
}

const root = process.cwd();
const manifest = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));

/** The npm packages imported (statically or dynamically, type-only imports excluded) by the .ts files under `dirs`. */
function importedPackages(dirs: string[]): string[] {
  const transpilers = { ts: new Bun.Transpiler({ loader: "ts" }), tsx: new Bun.Transpiler({ loader: "tsx" }), js: new Bun.Transpiler({ loader: "js" }) };
  const packages = new Set<string>();
  for (const dir of dirs) {
    for (const file of new Bun.Glob("**/*.{ts,tsx,mjs,js}").scanSync(dir)) {
      const transpiler = file.endsWith(".tsx") ? transpilers.tsx : file.endsWith(".ts") ? transpilers.ts : transpilers.js;
      const source = readFileSync(join(dir, file), "utf8").replace(/^#!.*/, "");
      for (const { path } of transpiler.scanImports(source)) {
        if (path.startsWith(".") || path.startsWith("/") || path.startsWith("node:") || path.startsWith("bun")) continue;
        const parts = path.split("/");
        packages.add(path.startsWith("@") ? parts.slice(0, 2).join("/") : parts[0]!);
      }
    }
  }
  return [...packages].sort();
}
// @lydell/node-pty is only loaded by server/pty/pty-host.mjs under Node, the fallback for the Rust PTY
// host this package ships, so it and its prebuilt addons are left out.
const NOT_SHIPPED = new Set(["@lydell/node-pty"]);
const SERVER_RUNTIME = importedPackages(sourceDirs).filter((name) => !NOT_SHIPPED.has(name));
console.log(`npm packages imported by the shipped sources: ${SERVER_RUNTIME.join(" ")}`);

/** Resolves `name` the way node does, starting from the package directory `from`. */
function resolvePackage(name: string, from: string): string | null {
  let dir = from;
  for (;;) {
    const candidate = join(dir, "node_modules", name);
    if (existsSync(join(candidate, "package.json"))) return candidate;
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

/** The package directories of `names` and everything they depend on (dependencies + optionalDependencies). */
function closure(names: string[]): Set<string> {
  const found = new Set<string>();
  const queue = names.map((name) => ({ name, from: root, optional: false }));
  while (queue.length > 0) {
    const { name, from, optional } = queue.shift()!;
    const dir = resolvePackage(name, from);
    if (dir === null) {
      if (optional) continue;
      throw new Error(`cannot resolve ${name} from ${from}`);
    }
    if (found.has(dir)) continue;
    found.add(dir);
    const pkg = JSON.parse(readFileSync(join(dir, "package.json"), "utf8"));
    for (const dep of Object.keys(pkg.dependencies ?? {})) queue.push({ name: dep, from: dir, optional: false });
    for (const dep of Object.keys(pkg.optionalDependencies ?? {})) queue.push({ name: dep, from: dir, optional: true });
  }
  return found;
}

const server = closure(SERVER_RUNTIME);
const client = closure(Object.keys(manifest.dependencies).filter((name) => !NOT_SHIPPED.has(name)));

for (const dir of server) {
  const rel = dir.slice(join(root, "node_modules").length + 1);
  cpSync(dir, join(outDir, rel), { recursive: true, dereference: true });
}

const LICENSE_FILE = /^(licen[cs]e|copying|notice)/i;
const sections: string[] = [];
const missing: string[] = [];
for (const dir of [...new Set([...server, ...client])].sort()) {
  const pkg = JSON.parse(readFileSync(join(dir, "package.json"), "utf8"));
  let texts = readdirSync(dir).filter((file) => LICENSE_FILE.test(file)).sort().map((file) => readFileSync(join(dir, file), "utf8").trim());
  if (texts.length === 0) {
    // a license fetched by the recipe (npm-licenses/<name>), else a README that carries the license text
    const fetched = join(root, "npm-licenses", pkg.name.replace("/", "__"));
    const readme = readdirSync(dir).find((file) => /^readme/i.test(file));
    const readmeText = readme ? readFileSync(join(dir, readme), "utf8") : "";
    if (existsSync(fetched)) texts = [readFileSync(fetched, "utf8").trim()];
    else if (/Permission is hereby granted/.test(readmeText)) texts = [readmeText.trim()];
  }
  if (texts.length === 0) {
    missing.push(`${pkg.name}@${pkg.version}`);
    continue;
  }
  sections.push(`${"=".repeat(80)}\n${pkg.name}@${pkg.version} (${pkg.license ?? "unknown license"})\n${"=".repeat(80)}\n\n${texts.join("\n\n")}\n`);
}
writeFileSync(licensesFile, sections.join("\n"));
if (missing.length > 0) {
  console.error(`packages without a license file:\n  ${missing.join("\n  ")}`);
  process.exit(1);
}
console.log(`copied ${server.size} runtime packages, collected ${sections.length} licenses`);
