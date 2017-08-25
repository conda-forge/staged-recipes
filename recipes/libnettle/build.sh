#!/bin/bash
./configure --prefix="${PREFIX}" --libdir="${PREFIX}/lib/" --with-lib-path="${PREFIX}/lib/"
make
make check
make install

