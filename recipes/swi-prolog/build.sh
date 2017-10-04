#!/bin/bash


##strictly use anaconda build environment
#CXX=${PREFIX}/bin/g++

#to fix problems with zlib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"


./prepare --yes
./configure --prefix=$PREFIX
make VERBOSE=1
make install
curdir=${PWD}
for package in packages/*; do
    echo "Package: $package"
    cd $curdir/$package && ./configure --prefix=$PREFIX && make && (make install || true)
done

