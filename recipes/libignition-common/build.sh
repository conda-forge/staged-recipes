#!/bin/sh

# Need librt on Linux for time operations.
if [ "$(uname)" == "Linux" ]
then
  export LDFLAGS="${LDFLAGS} -lrt"
fi

mkdir build
cd build

cmake .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DCMAKE_CXX_STANDARD=17

cmake --build . --config Release
cmake --build . --config Release --target install
ctest -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION|UNIT_Filesystem_TEST" -VV
