#!/bin/bash

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install
