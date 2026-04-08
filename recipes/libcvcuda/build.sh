#!/bin/bash
set -euo pipefail

mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"

# Enable glibc compat layer when targeting glibc < 2.34.
# c_stdlib_version is set by conda-build from the variant (e.g. "2.17" or "2.28").
GLIBC_MINOR=$(echo "${c_stdlib_version}" | cut -d. -f2)
if [ "${GLIBC_MINOR:-0}" -lt 34 ]; then
    ENABLE_COMPAT_OLD_GLIBC=ON
else
    ENABLE_COMPAT_OLD_GLIBC=OFF
fi

export CFLAGS="${CFLAGS} -w"
export CXXFLAGS="${CXXFLAGS} -w"

cmake ${CMAKE_ARGS} "${SRC_DIR}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTS=OFF \
    -DBUILD_PYTHON=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_BENCH=OFF \
    -DENABLE_COMPAT_OLD_GLIBC=${ENABLE_COMPAT_OLD_GLIBC} \
    -DPUBLIC_API_COMPILERS="${CC};${CXX}" \
    -G Ninja

cmake --build . -j${CPU_COUNT}
