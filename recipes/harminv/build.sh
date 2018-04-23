#!/bin/bash

./configure --prefix="${PREFIX}" --enable-shared --with-blas=openblas
make
make check
make install
