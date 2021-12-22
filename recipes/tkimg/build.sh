#!/bin/bash

autoreconf --force --install

configure_args=(
    --prefix="${PREFIX}"
    --with-tcl="${PREFIX}/lib"
    --with-tk="${PREFIX}/lib"
)

if [[ ${ARCH} == 64 ]]; then
    configure_args+=(
        --enable-64bit
    )
fi

./configure "${configure_args[@]}"

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
