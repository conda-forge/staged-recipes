#!/bin/bash
set -euxo pipefail

# WCT derives its version from `git describe` when built from a clone. We build
# from a release tarball (no .git), so the wscript falls back to version.txt.
# This bare (digit-leading) version puts WCT's wscript in RELEASE mode
# (is_development() is false) -> it adds "-Werror -Wall -pedantic". That strict
# build is what we WANT for a shipped package; the -Werror sites are handled by
# recipe source patches plus the one targeted downgrade below.
echo "${PKG_VERSION}" > version.txt

# Let waf find the pkg-config'able deps (spdlog, fftw3f, jsoncpp, eigen3, tbb,
# hdf5) inside the conda prefix.
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# Demote ONLY the known GCC-13+ false positive on boost::multi_array
# (-Wdangling-reference) from error back to warning. -Werror stays on for
# everything else. The genuine warning sites are fixed via recipe patches
# (see source.patches in recipe.yaml), not by widening this list.
export CXXFLAGS="-Wno-error=dangling-reference ${CXXFLAGS:-}"

# waf's find_program('python') otherwise resolves to the HOST-env python, which
# is a non-executable relocation placeholder during the build (a host dep pulls
# python into $PREFIX). Force waf to the build-env interpreter, which is the one
# actually runnable now. waf honors the PYTHON env var as a find_program override.
export PYTHON="${BUILD_PREFIX}/bin/python"

./wcb configure \
    --prefix="${PREFIX}" \
    --boost-includes="${PREFIX}/include" \
    --boost-libs="${PREFIX}/lib" \
    --with-jsonnet="${PREFIX}"

./wcb -j"${CPU_COUNT}"
./wcb install
