#!/bin/bash

./configure --enable-mat73 --enable-extended-sparse --prefix="${PREFIX}" --with-zlib="${PREFIX}" --with-hdf5="${PREFIX}"
make

if [[ `uname` == 'Darwin' ]];
then
	eval DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib make check
else
	make check
fi

make install
