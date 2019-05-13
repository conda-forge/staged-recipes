#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sh bootstrap.sh

./configure \
    --prefix="${PREFIX}" \
    --with-globus-lib="${PREFIX}/lib" \
    --with-globus-include="${PREFIX}/include" \
    --with-krb5-gssapi-include="${PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    sed -i 's/notelnet="0"/notelnet="1"/g' configure
fi

make -j${CPU_COUNT}
make check
make install
make installcheck
