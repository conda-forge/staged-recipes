#!/bin/bash

# c.f. https://conda-forge.org/docs/maintainer/knowledge_base/#cross-compilation-examples
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf --install --force

./configure --help

# Don't use --enable-allplugins as the Fortran wrapper uses libquadmath which
# limits the use of the library on macOS
./configure \
  --prefix=$PREFIX \
  --enable-static=no \
  --enable-cgal=$PREFIX \
  --enable-thread-safety \
  --enable-siscone \
  --enable-allcxxplugins

make --jobs="${CPU_COUNT}"

# Skip ``make check`` when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check
fi
make install
make clean
