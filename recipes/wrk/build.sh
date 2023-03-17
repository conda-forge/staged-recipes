#!/bin/bash

set -euxo pipefail

# LuaJIT's Makefiles hardcode the compiler to "gcc".
# Patching is non-trivial because the sources are inside a .zip archive.
ln -s $CC "$BUILD_PREFIX"/bin/gcc

make WITH_OPENSSL="${PREFIX}"
cp wrk "${PREFIX}"/bin/
