#!/bin/bash

# c.f. https://conda-forge.org/docs/maintainer/knowledge_base/#cross-compilation-examples
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf --install

./configure --help

# Remove static library to comply with CFEP-18
# https://github.com/conda-forge/cfep/blob/main/cfep-18.md
./configure \
    --prefix=$PREFIX \
    --enable-static=no \
    --with-avholo="$FFLAGS -lavh_olo" \
    --with-looptools="$FLDFLAGS -looptools -lgfortran -lquadmath" \
    FCINCLUDE="${FCINCLUDE} -I$PREFIX/include/oneloop"

# Makefile is not parallel safe so can't use 'make --jobs="${CPU_COUNT}"'
make

# Skip ``make check`` when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check
fi
make install
make clean
