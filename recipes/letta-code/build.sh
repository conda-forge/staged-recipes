#!/usr/bin/env bash
set -euxo pipefail
export npm_config_cache="${SRC_DIR}/.npm-cache"
export npm_config_nodedir="${PREFIX}"
export npm_config_python="${BUILD_PREFIX}/bin/python"
export NODE_USE_SYSTEM_CA=1
export SCARF_ANALYTICS=false
export DO_NOT_TRACK=1
# Cursor's optional integration uses proprietary prebuilt native SDKs.
# Keep the normal Letta agent workflow independent of that integration.
"${BUILD_PREFIX}/bin/python" - <<'PYTHON'
import json
from pathlib import Path
for filename in ('package.json', 'npm-shrinkwrap.json'):
    path = Path(filename)
    data = json.loads(path.read_text())
    data.get('dependencies', {}).pop('@cursor/sdk', None)
    packages = data.get('packages', {})
    packages.get('', {}).get('dependencies', {}).pop('@cursor/sdk', None)
    for name in list(packages):
        if name.startswith('node_modules/@cursor/'):
            del packages[name]
    path.write_text(json.dumps(data, indent=2) + '\n')
PYTHON
npm install --global --prefix "${PREFIX}" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
root="${PREFIX}/lib/node_modules/@letta-ai/letta-code"
# Use conda's ripgrep and libvips, and compile native add-ons from source.
find "${root}/node_modules" -depth -type d \( -name 'ripgrep' -o -name 'ripgrep-*' \) -path '*/@vscode/*' -exec rm -rf {} +
find "${root}/node_modules" -depth -type d -path '*/@janhapke' -exec rm -rf {} +
find "${root}/node_modules" -depth -type d -path '*/@img/sharp-*' -exec rm -rf {} +
npm install --prefix "${SRC_DIR}/node-gyp" --ignore-scripts --no-audit --no-fund node-gyp@13.1.0
export NODE_PATH="${SRC_DIR}/node-gyp/node_modules"
while IFS= read -r pty; do
  (cd "${pty}"; rm -rf prebuilds third_party; npm run install)
done < <(find "${root}/node_modules" -type d -name node-pty)
while IFS= read -r sharp; do
  # sharp otherwise prepends Homebrew and pkg-config's build-prefix paths.
  "${BUILD_PREFIX}/bin/python" - "${sharp}" <<'PYTHON'
import sys
from pathlib import Path
path = Path(sys.argv[1]) / 'dist/libvips.cjs'
source = path.read_text()
old = 'getBrewPkgConfigPath(),\n      getPkgConfigPath(),\n      '
assert old in source, 'sharp pkg-config lookup changed'
path.write_text(source.replace(old, ''))
PYTHON
  (cd "${sharp}"; SHARP_FORCE_GLOBAL_LIBVIPS=1 npm run build; rm -rf src/build/Release/obj.target)
  binary=$(find "${sharp}/src/build/Release" -maxdepth 1 -name 'sharp-*.node' -print -quit)
  sharp_version=$(node -p "require('${sharp}/package.json').version")
  package=$(basename "${binary}" .node)
  package=${package%-${sharp_version}}
  mkdir -p "$(dirname "${sharp}")/@img/${package}"
  ln -s "../../sharp/src/build/Release/$(basename "${binary}")" "$(dirname "${sharp}")/@img/${package}/sharp.node"
done < <(find "${root}/node_modules" -type d -name sharp)
(cd "${root}"; node scripts/postinstall-patches.js)
"${BUILD_PREFIX}/bin/python" "${RECIPE_DIR}/licenses.py" "${root}" "${SRC_DIR}/bundled-licenses" "${SRC_DIR}/THIRDPARTY.txt"

mkdir -p "${PREFIX}/share/doc/letta-code"
cp "${RECIPE_DIR}/conda-notes.md" "${PREFIX}/share/doc/letta-code/conda-notes.md"
