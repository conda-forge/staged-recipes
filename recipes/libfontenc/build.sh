#!/usr/bin/env bash
set -ex

meson setup builddir ${MESON_ARGS} \
    -Ddefault_library=shared

meson compile -C builddir -j ${CPU_COUNT}
meson install -C builddir

# Requires.private and Libs.private are not meaningful in the context of
# shared libraries on conda-forge; strip them so downstream recipes are not
# burdened with transitive private build deps (e.g. fontenc.pc -> zlib).
# https://github.com/conda-forge/conda-forge.github.io/issues/1880#issuecomment-3677840586
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +
find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete

# Man pages are not useful inside a conda environment.
rm -rf "${PREFIX}/share/man"
