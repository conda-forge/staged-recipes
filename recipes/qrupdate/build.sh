#!/bin/bash

make solib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
make test 

if [ `uname` == Darwin ]; then
    make -B install FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
else
    make install PREFIX=${PREFIX}
fi
