#!/bin/bash
set -e -x

# Cf. https://github.com/conda-forge/staged-recipes/issues/673, we're in the
# process of excising Libtool files from our packages. Existing ones can break
# the build while this happens. We have "/." at the end of $PREFIX to be safe
# in case the variable is empty.
find $PREFIX/. -name '*.la' -delete

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
    --disable-selective-werror
    --disable-silent-rules
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

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/${PKG_NAME}

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find ${PREFIX}/. -name '*.la' -delete
