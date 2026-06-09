#!/usr/bin/env bash
set -ex

meson setup builddir ${MESON_ARGS}

meson compile -C builddir -j ${CPU_COUNT}
meson install -C builddir

# https://github.com/conda-forge/conda-forge.github.io/issues/1880
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +
find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete

rm -rf "${PREFIX}/share/man"
