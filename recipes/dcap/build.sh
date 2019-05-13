#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sh bootstrap.sh

declare -a PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    PLATFORM_FLAGS+=(--with-sysroot="${PREFIX}")
else
    PLATFORM_FLAGS+=(--with-sysroot="${CONDA_BUILD_SYSROOT}")
fi

./configure \
    "${PLATFORM_FLAGS[@]}" \
    --prefix="${PREFIX}" \
    --with-globus-lib="${PREFIX}/lib" \
    --with-globus-include="${PREFIX}/include" \
    --with-krb5-gssapi-include="${PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    sed -i 's/notelnet="0"/notelnet="1"/g' configure
fi

make -j${CPU_COUNT}
make install
