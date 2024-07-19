#!/usr/bin/env bash

set -euxo pipefail

# Python client
sed -i "s/version=0.0.0/${PKG_VERSION}/g" v4-proto-py/setup.py
make v4-proto-py-gen

# JavaScript client
cd v4-proto-js
  # Don't use pre-built gyp packages
  export npm_config_build_from_source=true

  # Patch version
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/0.0.0/${PKG_VERSION}/g" package.json
  else
    sed -i "s/0.0.0/${PKG_VERSION}/g" package.json
  fi

  # pnpm import
  pnpm install
  pnpm run transpile

  find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  pnpm add @cosmjs/tendermint-rpc @types/node
  pnpm add long@5.2.3

  pnpm run build
cd ..

# Install
cd v4-proto-py
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"
cd ..
touch "$RECIPE_DIR/ThirdPartyLicenses.txt"
