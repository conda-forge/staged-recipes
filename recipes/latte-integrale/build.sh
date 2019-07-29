#!/bin/bash

./configure --prefix=$PREFIX --with-ntl=$PREFIX || (cat config.log; false)
make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install
