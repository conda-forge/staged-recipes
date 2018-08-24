#!/bin/bash

./configure CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib" --prefix="${PREFIX}"
make
make install
