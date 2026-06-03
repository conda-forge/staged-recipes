#!/usr/bin/env bash
#  Copyright (c) The Einsums Developers. All rights reserved.
#  Licensed under the MIT License. See LICENSE.txt in the project root.
set -euxo pipefail

# ${CMAKE_ARGS} carries conda-forge's toolchain file, sysroot, and rpath setup.
# ${PREFIX} on CMAKE_PREFIX_PATH lets find_package(Clang/LLVM CONFIG) resolve the
# host clangdev/llvmdev.
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build
cmake --install build
