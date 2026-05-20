#!/usr/bin/env bash
set -exo pipefail

export SHARP_IGNORE_GLOBAL_LIBVIPS=1
export npm_config_sharp_ignore_global_libvips=true

sed -i.bak 's/^minimumReleaseAge: .*/minimumReleaseAge: 0/' pnpm-workspace.yaml

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --prod
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
mv package.json.bak package.json
rm -rf node_modules

# Build and pack the package
pnpm install
pnpm build
pnpm ui:build
pnpm pack --config.ignore-scripts=true

# Force sharp to use conda-forge libvips and build native binding locally
unset SHARP_IGNORE_GLOBAL_LIBVIPS
unset npm_config_sharp_ignore_global_libvips
export SHARP_FORCE_GLOBAL_LIBVIPS=1
export npm_config_sharp_build_from_source=true
export npm_config_sharp_force_global_libvips=true
export npm_config_build_from_source=true
export npm_config_node_gyp="${BUILD_PREFIX}/bin/node-gyp"
export NODE_PATH="${BUILD_PREFIX}/lib/node_modules:${NODE_PATH:-}"
export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export PYTHON="${BUILD_PREFIX}/bin/python"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"
pkg-config --modversion vips-cpp
pkg-config --cflags vips-cpp
pkg-config --libs vips-cpp

npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --build-from-source \
    --foreground-scripts \
    ${PKG_NAME}-${PKG_VERSION}.tgz
