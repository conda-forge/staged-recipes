#!/bin/bash
set -e
set -x

autoreconf -fi
./configure --prefix="${PREFIX}" \
  --with-hdf5="${PREFIX}" \
  --enable-shared \
  --enable-dagmc \
  --enable-tools \
  || { cat config.log; exit 1; }
make -j "${CPU_COUNT}"
if [ "$(uname)" == "Linux" ]; then
  # tests fail to link on mac becaue HDF5 rpaths haven't been rewritten yet.
  make check \
    || { cat itaps/imesh/test-suite.log; exit 1; }
fi
make install
