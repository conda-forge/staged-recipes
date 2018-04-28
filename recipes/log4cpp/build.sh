#!/bin/bash

./configure --prefix="${PREFIX}" --with-pthreads
make -j${CPU_COUNT}
make check
make install
