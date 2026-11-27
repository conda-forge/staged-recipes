#!/bin/bash
set -euxo pipefail

# Build the C/C++ library and tools without Python bindings or optional SIONlib.
export PYTHON=:
export PYTHON_FOR_GENERATOR=:
export SPHINX=:

# OTF2's platform defaults override environment variables unless passed here.
./configure \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    --prefix="${PREFIX}" \
    --libdir="${PREFIX}/lib" \
    --disable-silent-rules \
    --enable-shared \
    --disable-static \
    --without-sionlib \
    --enable-backend-test-runs

make -j"${CPU_COUNT}"
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
    make -j"${CPU_COUNT}" check
fi
make install

rm -f "${PREFIX}"/lib/*.la
rm -rf "${PREFIX}/share/doc/otf2"
