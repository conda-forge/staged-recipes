#!/usr/bin/env bash

set -eux

cargo-bundle-licenses --format yaml  --output THIRDPARTY_LICENSES.yaml

cmake -G Ninja $CMAKE_ARGS \
    -DBUILD_SHARED_LIBS=ON \
    -DRUST_BUILD_TARGET=$CARGO_BUILD_TARGET \
    -DMETATENSOR_INSTALL_BOTH_STATIC_SHARED=OFF \
    .

cmake --build . --config Release --target install
