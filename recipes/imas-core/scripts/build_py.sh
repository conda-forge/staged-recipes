#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Disable availability macros to avoid issues with older C++ standard libraries
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
export MESON_ARGS="${MESON_ARGS} --pkg-config-path=${PREFIX}/lib/pkgconfig"

# Build and install by pip with meson-python backend (PEP)
$PYTHON -m pip install . --no-deps --no-build-isolation -vv \
    -Cbuilddir=builddir \
    -Csetup-args=-Dal_core=false \
    -Csetup-args=-Dpython_bindings=true
    || (cat builddir/meson-logs/meson-log.txt && exit 1)