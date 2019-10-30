#!/bin/bash

CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

cd src/github.com/cockroachdb/${PKG_NAME}
make build

