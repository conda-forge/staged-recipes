#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Disable availability macros to avoid issues with older C++ standard libraries
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
export MESON_ARGS="${MESON_ARGS} --pkg-config-path=${PREFIX}/lib/pkgconfig"

# Configure
meson setup builddir ${MESON_ARGS} \
    -D al_core=false \
    -D python_bindings=false \
    -D al_dummy_exe=true \
    -D al_test=true \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)

# Run tests
meson test -C builddir --verbose \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)
