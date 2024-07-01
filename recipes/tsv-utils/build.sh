#!/bin/bash

set -x

make DCOMPILER=ldc2 DFLAGS="-L-L${PREFIX}/lib -L-Wl,-rpath,${PREFIX}/lib"
make test-nobuild DCOMPILER=ldc2

cp -r bin $PREFIX
