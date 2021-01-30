#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib
cp lib2/libLLVM* lib/
if [[ "$PKG_NAME" == "libmlir" ]]; then
    cp lib2/libMLIR${SHLIB_EXT} lib/
    cp lib2/libmlir_runner_utils${SHLIB_EXT} lib/
    cp lib2/libmlir_c_runner_utils${SHLIB_EXT} lib/
else
    cp lib2/libMLIR.*.* lib/
    cp lib2/libmlir_runner_utils.*.* lib/
    cp lib2/libmlir_c_runner_utils.*.* lib/
fi
rm -rf lib2

