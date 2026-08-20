#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

extra_args=""
if [[ ${target_platform} =~ .*linux.* ]]; then
    extra_args+="--cc=gcc "
    extra_args+="--without-os-features=getrandom,getentropy,explicit_bzero "
else
    rm src/tests/test_tls_session_manager.cpp
fi

./configure.py \
    --prefix=${PREFIX} \
    ${extra_args} \
    --with-bzip \
    --with-lzma \
    --with-zlib \
    --with-boost \
    --with-sqlite3
make -j${CPU_COUNT}
make check
make install
