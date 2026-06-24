#!/usr/bin/env bash
set -euxo pipefail

# Ensure the build uses the conda compilers where possible
export CC="${CC:-cc}"
export FC="${FC:-gfortran}"

# Build
cd src
make

# Install
mkdir -p "${PREFIX}/bin"

# Install canonical name
install -m 0755 DAlphaBall.gcc "${PREFIX}/bin/dalphaball"

# Alias name (same executable, second entry point)
ln -sf "dalphaball" "${PREFIX}/bin/DAlphaBall.gcc"
