#!/bin/bash
set -e -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${PREFIX}/include/glib-2.0 -I${PREFIX}/lib/glib-2.0/include"

export CONFIG_FLAGS="--build=${BUILD}"

export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
configure_args=(
    ${CONFIG_FLAGS}
    --disable-debug
    --disable-dependency-tracking
    --with-x
    --prefix="${PREFIX}"
)

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]] ; then
    configure_args+=(
        --enable-malloc0returnsnull
    )
fi

./configure "${configure_args[@]}"
make -j${CPU_COUNT}
make install

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/wmctrl

find ${PREFIX}/. -name '*.la' -delete
