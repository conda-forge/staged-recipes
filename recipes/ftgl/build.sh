#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -ex

declare -a PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    CMAKE_PLATFORM_FLAGS+=("--with-gl-lib=${CONDA_BUILD_SYSROOT}/usr/lib64/libGL.so")
fi

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --disable-freetypetest \
    --with-glut-inc=/dev/null \
    --with-glut-lib=/dev/null \
    "${PLATFORM_FLAGS}"

make install
