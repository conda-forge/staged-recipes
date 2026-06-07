#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm $PREFIX/bin/node
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

# Set the version in package.json since it is not tracked in source
npm version "${PKG_VERSION}"

pnpm install
pnpm build
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    "${SRC_DIR}"/renovate-"${PKG_VERSION}".tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create Unix bin wrapper
#mkdir -p "${PREFIX}"/bin
#tee "${PREFIX}"/bin/renovate << 'EOF'
#!/bin/sh
#exec node "$CONDA_PREFIX/lib/node_modules/renovate/dist/renovate.js" "$@"
#EOF
#chmod +x "${PREFIX}"/bin/renovate