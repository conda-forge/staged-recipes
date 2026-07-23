#!/bin/bash
set -euxo pipefail

# --- Vendored ERFA -----------------------------------------------------------
# ERFA has no conda-forge feedstock, so its release tarball is fetched as a
# second source (staged in subprojects/_erfa_src/).  meson's subprojects/erfa.wrap
# expects the unpacked source at subprojects/erfa-2.0.1/, which lets meson build
# it as a subproject with no network access.  conda-build's exact extraction
# layout for a secondary source can vary (leading directory stripped or not), so
# locate ERFA's root by its unique erfa.pc.in and move it into place.
if [ ! -f subprojects/erfa-2.0.1/meson.build ]; then
    erfa_root=$(dirname "$(find subprojects/_erfa_src -name erfa.pc.in | head -n1)")
    mkdir -p subprojects/erfa-2.0.1
    ( shopt -s dotglob nullglob; mv "${erfa_root}"/* subprojects/erfa-2.0.1/ )
fi

# PGPLOT headers: conda-forge's pgplot ships cpgplot.h under <prefix>/include/pgplot
# and its data (rgb.txt, fonts) under <prefix>/share/pgplot.  meson.build probes
# $PGPLOT_DIR as a fallback for the header; set it (and it is the runtime data dir).
export PGPLOT_DIR="${PREFIX}/share/pgplot"

# pkg-config must search both lib/pkgconfig and share/pkgconfig: conda-forge's
# xorg protocol .pc files (xproto.pc, kbproto.pc -- required by x11.pc) live in
# share/pkgconfig.  Prepend to whatever conda's activation already set.
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

# --- Stage 1: libpresto, C tools, man pages, runtime data --------------------
meson setup builddir \
    --prefix="${PREFIX}" \
    --libdir=lib \
    --buildtype=release
meson compile -C builddir -v
meson install -C builddir

# --- Stage 2: Python package + _presto extension -----------------------------
# The Python build links the libpresto just installed into ${PREFIX}/lib.
pushd python
${PYTHON} -m pip install . --no-build-isolation --no-deps -vv
popd
