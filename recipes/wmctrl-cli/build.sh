#!/bin/bash
set -e -x

export LDFLAGS="-L${PREFIX}/lib -lglib-2.0 -lX11 -lXmu -lICE -lSM ${LDFLAGS}"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/glib-2.0 -I${PREFIX}/lib/glib-2.0/include ${CPPFLAGS}"

export CONFIG_FLAGS="--build=${BUILD}"

export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
configure_args=(
    ${CONFIG_FLAGS}
    --disable-debug
    --disable-dependency-tracking
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
