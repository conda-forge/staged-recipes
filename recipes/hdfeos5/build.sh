#!/bin/sh

export CC=${PREFIX}/bin/h5cc
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-fPIC"

export HDF5_LDFLAGS="-L ${PREFIX}/lib"

./configure --prefix=${PREFIX} --with-hdf5=${PREFIX} --with-zlib=${PREFIX}

make
make check
make install

pushd include
make install-includeHEADERS
popd
