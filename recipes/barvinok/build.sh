#!/bin/bash

set -x


./configure --prefix=$PREFIX --enable-shared-barvinok

make -j${CPU_COUNT}

make install
