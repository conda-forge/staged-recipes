#!/bin/bash

./autogen.sh

./configure --prefix=${PREFIX} --disable-static --disable-doc

make -j${CPU_COUNT}

make install