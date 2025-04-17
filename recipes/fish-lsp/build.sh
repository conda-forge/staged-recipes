#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

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

# Move transpiled javascript from out to dist so that npm pack notices it
# Then symlink out back to dist so post install works
mv out dist
ln -sf dist out

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
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Delete empty out directory from ${PREFIX}/lib/node_modules/fish-lsp
# and then symlink out back to dist so that bin wrapper script works
rm -rf ${PREFIX}/lib/node_modules/fish-lsp/out
ln -sf ${PREFIX}/lib/node_modules/fish-lsp/dist ${PREFIX}/lib/node_modules/fish-lsp/out

# Create license report for dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
