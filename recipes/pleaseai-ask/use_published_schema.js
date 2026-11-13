// The CLI depends on its sibling workspace package @pleaseai/ask-schema via
// "workspace:^", which npm/pnpm can't resolve outside the monorepo. Point it at
// the same version published on npm (the one shipped in this source tag).
const fs = require("fs");
const path = require("path");
const root = process.argv[2];
const schema = JSON.parse(fs.readFileSync(path.join(root, "packages", "schema", "package.json"), "utf8"));
const cliPath = path.join(root, "packages", "cli", "package.json");
const cli = JSON.parse(fs.readFileSync(cliPath, "utf8"));
cli.dependencies["@pleaseai/ask-schema"] = schema.version;
fs.writeFileSync(cliPath, JSON.stringify(cli, null, 2) + "\n");
console.log("@pleaseai/ask-schema ->", schema.version);
