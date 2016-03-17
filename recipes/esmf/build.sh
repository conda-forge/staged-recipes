#!/bin/bash

if [[ $(uname) == Linux ]]; then
yum install -y gcc-gfortran
fi

export ESMF_DIR=$(pwd)
export ESMF_INSTALL_PREFIX=${PREFIX}
export ESMF_NETCDF="split"
export ESMF_NETCDF_INCLUDE=${PREFIX}/include
export ESMF_NETCDF_LIBPATH=${PREFIX}/lib

export ESMF_COMM=mpiuni

make -j ${CPU_COUNT}
make check
make install

# Ideally these files should be moved.
ln -s ${PREFIX}/bin/binO/*.default/* ${PREFIX}/bin
ln -s ${PREFIX}/lib/libO/*.default/*.a ${PREFIX}/lib
ln -s ${PREFIX}/mod/modO/*.default/* ${PREFIX}/mod
if [[ $(uname) == Darwin ]]; then
ln -s ${PREFIX}/lib/libO/*.default/*.dylib ${PREFIX}/lib
else
ln -s ${PREFIX}/lib/libO/*.default/*.so ${PREFIX}/lib
fi
