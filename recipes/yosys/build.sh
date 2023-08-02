#! /bin/bash

set -e
set -x

if [[ "${target_platform}" == "linux-64" ]]; then
    # expects `gcc`
    ln -s $GCC $BUILD_PREFIX/bin/gcc

    # TODO this doesnt work
    # alias gcc=$CC

    make CONFIG=gcc -j $(nproc)

else
    make CONFIG=clang -j $(sysctl -n hw.physicalcpu)
    
fi


# install
make install
