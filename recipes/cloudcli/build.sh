#!/usr/bin/env bash
set -euxo pipefail

# Use codex from PATH (conda-forge `codex`) instead of the npm-bundled binary.
f=server/modules/providers/list/codex/codex-runtime.provider.ts
sed -i "s/codex = new Codex();/codex = new Codex({ codexPathOverride: process.env.CODEX_CLI_PATH || 'codex' });/" "$f"
grep -q codexPathOverride "$f"

# node-gyp: build against the host Node headers
export npm_config_nodedir="$PREFIX"
export npm_config_build_from_source=true

# --ignore-scripts: skips husky, @vscode/ripgrep's binary download and prebuilt addons
npm ci --ignore-scripts --no-audit --no-fund
for m in node-pty bcrypt better-sqlite3; do
  rm -rf "node_modules/$m/prebuilds" "node_modules/$m/build"
done
npm rebuild --build-from-source node-pty bcrypt better-sqlite3
# rollup/esbuild ship their own install scripts for platform binaries
npm rebuild esbuild

npm run build
npm prune --omit=dev --ignore-scripts --no-audit --no-fund

# Drop bundled proprietary/third-party agent binaries and unused optional deps
rm -rf node_modules/@anthropic-ai/claude-agent-sdk-* \
       node_modules/@openai/codex-*-* \
       node_modules/@nut-tree-fork \
       node_modules/screenshot-desktop
# keep the codex-sdk package itself
test -d node_modules/@openai/codex-sdk

# ripgrep from conda-forge
mkdir -p node_modules/@vscode/ripgrep/bin
ln -sf ../../../../../../../../bin/rg node_modules/@vscode/ripgrep/bin/rg

node "$RECIPE_DIR/collect_licenses.js" node_modules > third-party-licenses.txt

dest="$PREFIX/lib/node_modules/@cloudcli-ai/cloudcli"
mkdir -p "$dest/public" "$PREFIX/bin"
cp -R package.json dist dist-server server shared scripts node_modules "$dest/"
cp public/api-docs.html "$dest/public/"
chmod +x "$dest/dist-server/server/modules/cli/cli.js"
ln -s ../lib/node_modules/@cloudcli-ai/cloudcli/dist-server/server/modules/cli/cli.js "$PREFIX/bin/cloudcli"
