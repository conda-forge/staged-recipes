#!/bin/bash
./autogen.sh
./configure --quiet --enable-shared --enable-mat73 --enable-extended-sparse --prefix="${PREFIX}" --with-zlib="${PREFIX}" --with-hdf5="${PREFIX}"
make
make install
