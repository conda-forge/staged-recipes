#!/bin/bash
set -e -x

export ACLOCAL_PATH="${PREFIX}/share/aclocal:${BUILD_PREFIX}/share/aclocal"
autoreconf_args=(
    --force
    --verbose
    --install
    -I "${PREFIX}/share/aclocal"
    -I "${BUILD_PREFIX}/share/aclocal"
)
autoreconf "${autoreconf_args[@]}"

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

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find ${PREFIX}/. -name '*.la' -delete
