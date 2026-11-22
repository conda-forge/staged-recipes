#!/bin/bash
set -euxo pipefail
export npm_config_cache="${SRC_DIR}/.npm-cache"
export NODE_GYP_FORCE_PYTHON="${BUILD_PREFIX}/bin/python"
export NODE_USE_SYSTEM_CA=1
export SCARF_ANALYTICS=false
export DO_NOT_TRACK=1
export SHARP_FORCE_GLOBAL_LIBVIPS=1

# The optional Cursor SDK contains proprietary prebuilt binaries.
npm pkg delete dependencies.@cursor/sdk
npm install --global --prefix "${PREFIX}" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
cd "${PREFIX}/lib/node_modules/@letta-ai/letta-code"
node scripts/postinstall-patches.js

# Replace npm's prebuilt native dependencies with conda libraries.
node -e "const fs = require('fs'); for (const p of fs.globSync('**/node_modules/{@vscode/ripgrep*,@img/sharp-*,@janhapke}')) fs.rmSync(p, {recursive:true, force:true});"
cd node_modules
patch -p1 < "${RECIPE_DIR}/native-deps.patch"
cd node-pty
rm -rf prebuilds third_party
node "${BUILD_PREFIX}/lib/node_modules/node-gyp/bin/node-gyp.js" rebuild --nodedir "${PREFIX}"
node scripts/post-install.js
rm -rf deps build/Release/obj.target
cd ../sharp/src
node "${BUILD_PREFIX}/lib/node_modules/node-gyp/bin/node-gyp.js" rebuild --nodedir "${PREFIX}"
rm -rf build/Release/obj.target
cd ../..
node -e "const fs = require('fs'); const binary = fs.globSync('sharp/src/build/Release/sharp-*.node')[0]; const name = require('./sharp/package.json').version; const dir = '@img/' + require('path').basename(binary).replace('-' + name + '.node', ''); fs.mkdirSync(dir, {recursive:true}); fs.writeFileSync(dir + '/sharp.node.js', 'module.exports = require(\"../../' + binary + '\");');"
cd ..

# Let npm enumerate the installed tree and pnpm-licenses collect its licenses.
npm query '*' > "${SRC_DIR}/npm-dependencies.json"
node -e "const fs = require('fs'); const dependencies = require(process.env.SRC_DIR + '/npm-dependencies.json').filter(p => p.name && p.version).map(p => ({...p, license:p.license || 'UNKNOWN', author:typeof p.author === 'object' ? p.author.name : p.author})); fs.writeFileSync(process.env.SRC_DIR + '/licenses.json', JSON.stringify({dependencies}));"
pnpm-licenses generate-disclaimer --json-input-file "${SRC_DIR}/licenses.json" --output-file "${SRC_DIR}/THIRDPARTY.txt"
# Preserve original license files and additional notices alongside the disclaimer.
node -e "const fs = require('fs'), path = require('path'); for (const p of fs.globSync('**/{LICENSE*,LICENCE*,license*,licence*,COPYING*,NOTICE*,*NOTICES*,*notices*,COPYRIGHT*,Copyright*,copyright*,ThirdParty*,third-party*}')) { const dest = path.join(process.env.SRC_DIR, 'third-party-licenses', p); fs.mkdirSync(path.dirname(dest), {recursive:true}); fs.cpSync(p, dest, {recursive:true}); }"
