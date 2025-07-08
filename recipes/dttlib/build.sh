#!/bin/sh

export LIBCLANG_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [[ ${target_platform} =~ .*linux.* ]]; then
    ln -sf ${PREFIX}/lib/libglib-2.0.so.0 ${PREFIX}/lib/libglib-2.0.so
fi
./gen_stub
$PYTHON -m pip install . -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ ${target_platform} =~ .*linux.* ]]; then
    rm ${PREFIX}/lib/libglib-2.0.so
fi
