#!/bin/bash

cd activemq-cpp

./autogen.sh
chmod +x configure

export CXXFLAGS="$CXXFLAGS -std=c++11"
./configure --prefix=$PREFIX --disable-static
make -j${CPU_COUNT}
make install
make check
