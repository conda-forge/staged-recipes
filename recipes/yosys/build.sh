#! /bin/bash

set -e
set -x

if [[ "${target_platform}" == "linux-64" ]]; then
    # expects `gcc`
    ln -s $GCC $BUILD_PREFIX/bin/gcc

    # TODO this doesnt work
    # alias gcc=$CC

    make CONFIG=gcc -j $(nproc)

    # run tests here since they're not portable
    make CONFIG=gcc test
else
    make CONFIG=clang -j $(sysctl -n hw.physicalcpu)
    
    # run tests here since they're not portable
    make CONFIG=clang test
fi


# install
make install
