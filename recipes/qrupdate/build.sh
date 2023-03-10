#!/bin/env bash

# make lib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" PREFIX=${PREFIX}
make solib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
# make lib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
# make solib FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
# make test FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops -fallow-argument-mismatch" PREFIX=${PREFIX}
# make test FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops -l$PREFIX/lib/libblas -l$PREFIX/lib/liblapack"

make test FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops -l${PREFIX}/lib/libblas -l$PREFIX/lib/liblapack" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}

make install

if [ `uname` == Darwin ]; then
    make -B install FC=${FC} FFLAGS="${FFLAGS} -fimplicit-none -O3 -funroll-loops" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX}
else
    make install PREFIX=${PREFIX}
fi
