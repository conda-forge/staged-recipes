#!/bin/bash

./configure CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib"
make
make install
