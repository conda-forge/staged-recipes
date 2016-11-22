#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX} --enable-sse
make install
