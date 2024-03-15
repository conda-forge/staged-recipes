#!/bin/bash

cd activemq-cpp

./autogen.sh
chmod +x configure

./configure --prefix=$PREFIX --disable-static
make -j${CPU_COUNT}
make install
make check
