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

# Replace npm's prebuilt dependencies with builds using conda libraries.
rm -rf node_modules/@vscode/ripgrep* node_modules/@img/sharp-* node_modules/@janhapke
cd node_modules
# node-pty: use Windows ConPTY without legacy winpty or a Spectre CRT requirement.
# sharp: use conda libvips headers/import libraries on Windows and disable
# building/copying npm vendor libraries; exclude Homebrew pkg-config paths on macOS.
patch -p1 < "${RECIPE_DIR}/native-deps.patch"

cd node-pty
rm -rf prebuilds third_party
"${BUILD_PREFIX}/bin/node-gyp" rebuild --nodedir "${PREFIX}"
npm run postinstall
rm -rf deps build/Release/obj.target
cd ../sharp/src
"${BUILD_PREFIX}/bin/node-gyp" rebuild --nodedir "${PREFIX}"
rm -rf build/Release/obj.target
cd ../..
# The bundled Letta code looks for sharp under @img.
for binary in sharp/src/build/Release/sharp-*.node; do
    name="${binary##*/}"
    destination="@img/${name%-*}"
    mkdir -p "${destination}"
    cp "${binary}" "${destination}/sharp.node"
done
cd ..

# Adapt npm's package metadata to pnpm-licenses' input format.
npm query '*' > "${SRC_DIR}/npm-dependencies.json"
jq '{dependencies: map(select(.name and .version)
    | .author |= (if type == "object" then .name else . end)
    | del(.author | nulls) | .license //= "UNKNOWN")}' "${SRC_DIR}/npm-dependencies.json" > "${SRC_DIR}/licenses.json"
pnpm-licenses generate-disclaimer --json-input-file "${SRC_DIR}/licenses.json" --output-file "${SRC_DIR}/THIRDPARTY.txt"

# Keep the original license files and additional attribution notices too.
find . -type f \( -iname '*license*' -o -iname '*licence*' -o -iname '*notice*' \
    -o -iname '*copying*' -o -iname '*copyright*' -o -iname '*thirdparty*' \) -print0 |
while IFS= read -r -d '' file; do
    destination="${SRC_DIR}/third-party-licenses/${file}"
    mkdir -p "$(dirname "${destination}")"
    cp "${file}" "${destination}"
done
