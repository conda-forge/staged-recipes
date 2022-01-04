#!/bin/bash

make lib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" PREFIX=${PREFIX}
make solib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}

if [ `uname` == Darwin ]; then
    make -B install FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
else
    make install PREFIX=${PREFIX}
fi
