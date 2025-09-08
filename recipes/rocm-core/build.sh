#!/bin/bash

# ROCM_VERSION needs to be explicitly defined from the CMake command line,
# see:
#  * https://github.com/spack/spack-packages/blob/d37780746a17e19848365a3090dd20071fe48012/repos/spack_repo/builtin/packages/rocm_core/package.py#L79
#  * https://github.com/ROCm/rocm-core/blob/rocm-6.4.3/CMakeLists.txt#L63

cmake -GNinja ${CMAKE_ARGS} -DROCM_VERSION=${PKG_VERSION} -Bbuild -S.
cmake --build ./build
cmake --install ./build
