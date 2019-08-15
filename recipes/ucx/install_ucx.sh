#!/bin/bash

set -xeuo pipefail

export CONDA_BUILD_SYSROOT="$(${CC} --print-sysroot)"

export CFLAGS="${CFLAGS} -I${CONDA_BUILD_SYSROOT}/usr/include"
export LDFLAGS="${LDFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib64"

# Disable CMA to workaround an upstream bug.
# xref: https://github.com/openucx/ucx/issues/3391
# xref: https://github.com/openucx/ucx/pull/3424

#./autogen.sh
./configure \
    --build="${BUILD}" \
    --host="${HOST}" \
    --prefix="${PREFIX}" \
    --disable-cma \
    --enable-mt \
    --with-gnu-ld \
    --with-rdmacm="/usr"

make -j${CPU_COUNT}
make install
