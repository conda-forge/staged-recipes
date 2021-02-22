#!/bin/bash

if [[ ${target_platform} == osx-* ]]
then
    
    ./configure --prefix=$PREFIX --with-x=no --enable-qt5 --without-included-boost --without-included-mythes
else
    ./configure --prefix=$PREFIX --enable-qt5 --without-included-boost --without-included-mythes
fi

make
make check
make install
