#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# c.f. https://conda-forge.org/docs/how-to/advanced/cross-compilation/#autotools
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf --install --force

./configure --help

# Ensure C++14 standard
# c.f. https://github.com/BAllanach/softsusy/blob/b9e5680c1a69b690812ba909abaa15f1a955fb8e/configure.ac#L14
export CXXFLAGS="${CXXFLAGS} -std=c++14"

./configure \
    --prefix="${PREFIX}" \
    --enable-shared=yes \
    --enable-static=no

# Build only the libraries and the executables
make --jobs "${CPU_COUNT}" programs

# During cross-compilation the target binaries cannot be executed, so for
# cross-compilation touch to make newer than the binaries so
# 'make install' copies them as-is.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" && "${CROSSCOMPILING_EMULATOR:-}" == "" ]]; then
    touch inOutFiles/*
fi

make install

# Don't distribute PDF files
rm "${PREFIX}"/share/softsusy/*.pdf
