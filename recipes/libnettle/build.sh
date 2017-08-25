#!/bin/bash
./configure --prefix="${PREFIX}" --libdir="${PREFIX}/lib/" --enable-mini-gmp
make
make check
make install

