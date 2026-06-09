#!/usr/bin/env bash
set -ex

# Refresh config.guess / config.sub so the conda cross-compilation triplets
# are recognised by the (autotools) build.
cp "${BUILD_PREFIX}/share/gnuconfig/config.guess" .
cp "${BUILD_PREFIX}/share/gnuconfig/config.sub" .

export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"

./configure \
    --prefix="${PREFIX}" \
    --build="${BUILD}" \
    --host="${HOST}" \
    --disable-static \
    --disable-dependency-tracking \
    --disable-selective-werror \
    --disable-silent-rules

make -j"${CPU_COUNT}"
make install

# Requires.private and Libs.private are not meaningful in the context of
# shared libraries on conda-forge; strip them so downstream recipes are not
# burdened with transitive private build deps (xfont2.pc -> fontenc/freetype2/zlib).
# https://github.com/conda-forge/conda-forge.github.io/issues/1880#issuecomment-3677840586
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +
find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete

# Man pages / docs are not useful inside a conda environment.
rm -rf "${PREFIX}/share/man" "${PREFIX}/share/doc"
