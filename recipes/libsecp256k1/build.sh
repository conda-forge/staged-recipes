#!/bin/bash

./autogen.sh
./configure --disable-shared --enable-static --disable-dependency-tracking --with-pic --enable-module-recovery --disable-jni --prefix $PREFIX --enable-experimental --enable-module-ecdh --enable-benchmark=no
make install
