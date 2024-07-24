#!/usr/bin/env bash

set -euxo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi
# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

pnpm install
pnpm install --save-dev @types/jest
pnpm run build

# Audit fails for the latest request version
# pnpm audit fix

pnpm install --prod --no-frozen-lockfile
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file="$SRC_DIR"/ThirdPartyLicenses.txt
pnpm pack

npm install -g "dydxprotocol-node-service-base-dev-${PKG_VERSION}.tgz"
