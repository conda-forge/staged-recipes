#!/usr/bin/env bash
set -ex

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

# https://github.com/conda-forge/conda-forge.github.io/issues/1880
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +
find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete

rm -rf "${PREFIX}/share/man" "${PREFIX}/share/doc"
