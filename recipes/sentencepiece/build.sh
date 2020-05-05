#!/bin/bash

mkdir build && cd build

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
export LD_LIBRARY_PATH=${PREFIX}/lib:${LD_LIBRARY_PATH}

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -DCMAKE_AR=$GCC_AR -DSPM_BUILD_TEST=ON -DSPM_ENABLE_TCMALLOC=OFF -DSPM_USE_BUILTIN_PROTOBUF=OFF -S ..

make -j $(nproc) && make install

if [[ "$target_platform" == linux* ]]; then
  ldconfig -v -N
elif [[ $target_platform == "osx-64" ]]; then
  update_dyld_shared_cache
fi

cd ..
cd python

${PYTHON} -m pip install . -vv
