#!/usr/bin/env bash

set -euxo pipefail

  # Don't use pre-built gyp packages
export npm_config_build_from_source=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

# JavaScript client
pushd v4-proto-js
  # Patch version
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/0.0.0/${PKG_VERSION}/g" package.json
  else
    sed -i "s/0.0.0/${PKG_VERSION}/g" package.json
  fi

  # Update package.json with conda packages: eslint, typescript-eslint, etc.
  rm -f package-lock.json
  for pkg in eslint @dydxprotocol/node-service-base-dev @typescript-eslint/eslint-plugin @typescript-eslint/parser; do
    pnpm install --save "${pkg}@file:${PREFIX}/lib/node_modules/${pkg}"
  done

  pnpm add @cosmjs/tendermint-rpc @types/node long@5.2.3

  # pnpm import
  pnpm install
  pnpm run transpile

  if [[ "$(uname)" == "Darwin" ]]; then
    find "src/codegen" -name "*.ts" -exec sed -i '' 's/\(e\) =>/(\1: any) =>/g' {} \;
  else
    find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  fi

  pnpm run build
popd
