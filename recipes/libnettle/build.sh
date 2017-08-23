#!/bin/bash




if [[ $(uname) == Darwin ]]; then
    ./configure --prefix="${PREFIX}" --disable-assembler 
elif [[ $(uname) == Linux ]]; then
    ./configure --prefix="${PREFIX}" 
fi



make

make check

make install

