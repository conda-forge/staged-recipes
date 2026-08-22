#!/bin/bash
set -euxo pipefail

# PGPLOT headers: conda-forge's pgplot ships cpgplot.h under <prefix>/include/pgplot
# and its data (rgb.txt, fonts) under <prefix>/share/pgplot.  meson.build probes
# $PGPLOT_DIR as a fallback for the header; set it (and it is the runtime data dir).
export PGPLOT_DIR="${PREFIX}/share/pgplot"

# pkg-config must search both lib/pkgconfig and share/pkgconfig: conda-forge's
# xorg protocol .pc files (xproto.pc, kbproto.pc -- required by x11.pc) live in
# share/pkgconfig.  Prepend to whatever conda's activation already set.
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

# --- Stage 1: libpresto, C tools, man pages, runtime data --------------------
# ${MESON_ARGS} supplies conda-forge's --prefix/-Dlibdir/-Dbuildtype and, when
# cross-compiling (e.g. osx-arm64), the generated cross file.
#
# --wrap-mode=nodownload keeps meson from falling back to subprojects/erfa.wrap:
# ERFA is provided by the liberfa package, so a missing erfa.pc must fail loudly
# at configure time rather than attempt a (network-less) subproject download.
# shellcheck disable=SC2086  # MESON_ARGS must word-split into separate arguments
meson setup builddir ${MESON_ARGS} --wrap-mode=nodownload
meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir

# --- Stage 2: Python package + _presto extension -----------------------------
# The Python build links the libpresto just installed into ${PREFIX}/lib.
pushd python
${PYTHON} -m pip install . --no-build-isolation --no-deps -vv
popd
