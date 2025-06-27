#!/usr/bin/env bash

# configure
cmake                                \
    -S ${SRC_DIR}                    \
    -B build                         \
    -DCMAKE_VERBOSE_MAKEFILE=ON      \
    ${CMAKE_ARGS}                    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

# build
cmake --build build --parallel ${CPU_COUNT}

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    echo "Skipping runtime tests due to cross-compiled target..."
else
    ctest --test-dir build --output-on-failure
fi

# install
cmake --build build --target install


