#!/bin/bash

set -x

make DCOMPILER=ldc2 DFLAGS="-L-L${PREFIX}/lib -L-rpath=${PREFIX}/lib"
make test-nobuild DCOMPILER=ldc2

# for fname in $(ls bin/*); do
#   patchelf --remove-rpath ${fname}
#   patchelf --add-rpath '$PREFIX/lib' ${fname}
#   patchelf --print-rpath ${fname}
#   readelf -d ${fname}
# done

cp -r bin $PREFIX
