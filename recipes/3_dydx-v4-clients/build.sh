#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

# Python client
cd v4-client-py-v2
  poetry build
cd ..

# C++ client
cd v4-client-cpp
  mkdir -p build
  cd build
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      --debug-find \
      -G Ninja > _cmake_configure.log 2>&1

    cmake --build . -- -j"${CPU_COUNT}"
  cd ..
cd ..

# JavaScript client
cd v4-client-js
  # Don't use pre-built gyp packages
  export npm_config_build_from_source=true

  # Patch version
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/0.0.0/${PKG_VERSION}/g" package.json
  else
    sed -i "s/0.0.0/${PKG_VERSION}/g" package.json
  fi

  rm -rf node_modules package-lock.json pnpm-lock.yaml
  pnpm cache clean --force
  pnpm install
  pnpm run transpile

  # find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  # pnpm add @cosmjs/tendermint-rpc @types/node
  # pnpm add long@5.2.3

  pnpm run build
cd ..
