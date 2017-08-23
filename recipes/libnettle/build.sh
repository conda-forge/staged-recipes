#!/bin/bash




if [[ $(uname) == Darwin ]]; then
    ./configure --prefix="${PREFIX}" 
elif [[ $(uname) == Linux ]]; then
    ./configure --prefix="${PREFIX}" --disable-assembler 
fi



make

make check

make install

