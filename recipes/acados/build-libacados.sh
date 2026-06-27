#!/usr/bin/env bash

set -euxo pipefail

# Pick a portable BLASFEO target for each architecture.  X64_AUTOMATIC compiles
# kernels for several x86-64 micro-architectures and dispatches at run time, so
# the resulting binary works on the whole conda-forge x86-64 user base.  ARM has
# no run-time dispatcher, so we select a conservative baseline per platform.
case "${target_platform:-}" in
  linux-64|osx-64)  BLASFEO_TARGET="X64_AUTOMATIC" ;;
  osx-arm64)        BLASFEO_TARGET="ARMV8A_APPLE_M1" ;;
  linux-aarch64)    BLASFEO_TARGET="ARMV8A_ARM_CORTEX_A57" ;;
  *)                BLASFEO_TARGET="GENERIC" ;;
esac

cmake -G Ninja -S . -B build ${CMAKE_ARGS:-} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DACADOS_INSTALL_DIR="${PREFIX}" \
  -DBUILD_SHARED_LIBS=ON \
  -DBLASFEO_TARGET="${BLASFEO_TARGET}" \
  -DACADOS_WITH_OPENMP=OFF \
  -DACADOS_PYTHON=OFF \
  -DACADOS_EXAMPLES=OFF \
  -DACADOS_UNIT_TESTS=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build

# acados writes link_libs.json (required by the Python/MATLAB code-generation
# interface to know which optional solver libraries to link against) and
# git_commit_hash into <source>/lib at configure time, but provides no install
# rule for either. Place them next to the installed libraries where
# acados_template looks for them (${ACADOS_SOURCE_DIR}/lib).
install -m 0644 lib/link_libs.json "${PREFIX}/lib/link_libs.json"
install -m 0644 lib/git_commit_hash "${PREFIX}/lib/git_commit_hash"

# Build the Tera template renderer (t_renderer) from its Rust source and install
# it next to the libraries.  The acados Python/MATLAB interfaces look for it at
# ${ACADOS_SOURCE_DIR}/bin/t_renderer; shipping it avoids the run-time download
# that acados would otherwise attempt.
pushd interfaces/acados_template/tera_renderer
  # Collect the licenses of the statically linked Rust dependencies.
  cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
  # `cargo install` installs the release binary to ${PREFIX}/bin regardless of
  # the (cross-)build target triple that conda-forge's rust pins via
  # CARGO_BUILD_TARGET; --no-track keeps the cargo bookkeeping files out of the
  # package.
  cargo install --no-track --root "${PREFIX}" --path .
popd

test -f "${PREFIX}/bin/t_renderer"
