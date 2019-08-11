#!/bin/bash

./configure --prefix=$PREFIX --with-tiff=$PREFIX --with-jpeg=$PREFIX
make -j${CPU_COUNT}
make check
make install
