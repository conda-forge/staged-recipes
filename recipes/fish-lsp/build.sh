#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Avoid limitations with install_name_tool rpath re-writing
if [[ "$(uname)" == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -Wl,-headerpad_max_install_names"
  export CXXFLAGS="${CXXFLAGS} -Wl,-headerpad_max_install_names"
  export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

# Fix package.json so it can bootstrap itself
# Remove preinstall script because it needs devDependencies that need to be installed with npm install
# Remove compile command from post install script so we don't try to transpile typescript again
mv package.json package.json.bak
jq "del(.scripts.preinstall)" package.json.bak > package.json
sed -i 's/setup compile sh:relink/setup sh:relink/' package.json

# Install depenendencies without running postinstall
npm install --ignore-scripts

# Remove tsc package and replace with typescript so we can transpile typescript
# and then manuall run compile script
npm uninstall tsc
npm install typescript
npm run compile

# Add fast-glob as a production dependency
npm install fast-glob --save-prod

# Create package archive
npm pack --ignore-scripts

# Symlink run-s from npm-run-all to ${SRC_DIR}/bin and add this folder to path
ln -sf ${SRC_DIR}/node_modules/npm-run-all/bin/run-s/index.js ${SRC_DIR}/bin/run-s
export PATH="${SRC_DIR}/bin:${PATH}"

# Install globally
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION//_/-}.tgz

# Create license report for dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
