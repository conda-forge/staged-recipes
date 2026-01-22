#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
export MESON_ARGS="${MESON_ARGS} --pkg-config-path=${PREFIX}/lib/pkgconfig"

# Configure
meson setup build ${MESON_ARGS} \
    -D al_core=false \
    -D python_bindings=false \
    -D al_dummy_exe=true \
    -D al_test=true

# Run tests
meson test -C build --verbose
