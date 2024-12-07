#!/bin/bash

set -ex

export CC=mpicc
export CXX=mpic++
export FC=mpifort

./configure --prefix="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-szlib="${PREFIX}" \
            --enable-cxx \
            --enable-fortran \
            --enable-threadsafe \
	    --enable-unsupported \
            --enable-build-mode=production \
	    --disable-dependency-tracking \
            --enable-static=no \
	    --with-default-api-version=v18 \
	    --disable-doxygen-doc

make -j ${CPU_COUNT}

make install
