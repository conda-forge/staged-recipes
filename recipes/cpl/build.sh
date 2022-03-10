#!/usr/bin/env bash

# CPL's custom M4 macro that detects FFTW needs to find its shared library.
# Putting the lib path directly in LD_LIBRARY_PATH does the trick,
# and is actually recommended by the CPL documentation,
# https://ftp.eso.org/pub/dfs/pipelines/libraries/cpl/docs/cpl-user-manual_6.0.pdf
env LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}" \
  ./configure --prefix=${PREFIX}
make
make check
make install

# The build produces some libtool `.la` files. Remove them. See
# https://github.com/conda-forge/conda-forge.github.io/issues/621
find ${PREFIX} -name '*.la' -delete
