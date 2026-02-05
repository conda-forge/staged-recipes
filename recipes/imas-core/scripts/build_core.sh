#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Set Boost paths (make sure Meson finds the correct Boost installation)
export BOOST_LIBRARYDIR="${PREFIX}/lib"
export BOOST_INCLUDEDIR="${PREFIX}/include"

# Disable availability macros to avoid issues with older C++ standard libraries
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
export MESON_ARGS="${MESON_ARGS} --pkg-config-path=${PREFIX}/lib/pkgconfig"

# Configure
meson setup build ${MESON_ARGS} \
    -D al_core=true \
    -D python_bindings=false

# Build and install
meson install -C build
