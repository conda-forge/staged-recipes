#!/bin/sh

set -exuo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi
# Don't use pre-built gyp packages
export npm_config_build_from_source=true

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

# source.url in meta.yaml references a tgz file which contains a fully-built pnpm-licenses
# version, we now want to turn this back into a tgz file using pnpm pack and install it
# globally from that.
# as we are doing pnpm pack we still need to include the node_modules which we retrieve
# using pnpm install
pnpm install
pnpm pack

# install pnpm-licenses globally from file (as opposed to from a registry as you'd do normally)
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install -g quantco-${PKG_NAME}-${PKG_VERSION}.tgz

# generate license disclaimer for pnpm-licenses itself :)
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
