#!/bin/bash

set -x

# Determine the OS type: macOS or Linux
OS_TYPE=$(uname -s)

if [ "$OS_TYPE" = "Darwin" ]; then
    # MacOS
    DFLAGS="-L-L${PREFIX}/lib -L-Wl,-rpath,${PREFIX}/lib"
else
    # Linux
    DFLAGS="-L-L${PREFIX}/lib -L-rpath=${PREFIX}/lib"
fi

make DCOMPILER=ldc2 DFLAGS="$DFLAGS"
make test-nobuild DCOMPILER=ldc2

# for fname in $(ls bin/*); do
#   if [ "$OS_TYPE" = "Linux" ]; then
#       patchelf --remove-rpath ${fname}
#       patchelf --add-rpath '$PREFIX/lib' ${fname}
#       patchelf --print-rpath ${fname}
#       readelf -d ${fname}
#   fi
# done

cp -r bin $PREFIX
