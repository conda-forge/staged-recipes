#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

# Handle arch differences
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

# Make sure node from build env is available for cross-compiles
if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm -f $PREFIX/bin/node || true
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

# Install dependencies and build Renovate
pnpm install --frozen-lockfile
pnpm run build

# Copy the CLI executable into $PREFIX/bin (cannot be a symlink)
mkdir -p $PREFIX/bin
cp $SRC_DIR/node_modules/.bin/renovate $PREFIX/bin/renovate
chmod +x $PREFIX/bin/renovate

# Generate third-party license report
pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt
