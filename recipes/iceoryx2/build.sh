#!/bin/bash

export LIBCLANG_PATH=$BUILD_PREFIX/lib

cmake ${CMAKE_ARGS} -DRUST_TARGET_TRIPLET=${CARGO_BUILD_TARGET} .
make -j${CPU_COUNT}
make install
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
