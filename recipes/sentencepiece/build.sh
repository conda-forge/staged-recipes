#!/bin/bash

mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -DCMAKE_AR="${AR}" -DSPM_BUILD_TEST=ON -DSPM_USE_BUILTIN_PROTOBUF=OFF -DSPM_ENABLE_TCMALLOC=OFF -S ..
make -j $(nproc)

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
export LD_LIBRARY_PATH=${PREFIX}/lib:${LD_LIBRARY_PATH}

make install

cd ..
cd python

${PYTHON} -m pip install . -vv
