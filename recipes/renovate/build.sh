#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm -f $PREFIX/bin/node
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

# Install dependencies and build
pnpm install --frozen-lockfile
pnpm build

# Copy the CLI entrypoint into $PREFIX/bin
mkdir -p $PREFIX/bin
# Symlink the main renovate executable (from node_modules/.bin)
ln -s $SRC_DIR/node_modules/.bin/renovate $PREFIX/bin/renovate

# Create license report
pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt
