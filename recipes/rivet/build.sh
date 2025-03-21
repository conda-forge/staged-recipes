#!/bin/bash

set -ex

# c.f. https://conda-forge.org/docs/maintainer/knowledge_base/#cross-compilation-examples
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf --install --force

./configure --help

./configure \
    --prefix=$PREFIX \
    --enable-shared=yes \
    --enable-static=no \
    --disable-doxygen \
    --with-yoda=$PREFIX \
    --with-hepmc3=$PREFIX \
    --with-fastjet=$PREFIX \
    --with-fjcontrib=$PREFIX \
    --with-zlib=$PREFIX \
    PYTHON=$PYTHON

make --jobs="${CPU_COUNT}"

# Skip ``make check`` when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check
fi
make install
make clean
