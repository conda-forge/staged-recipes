#!/bin/sh

mkdir build
cd build

cmake .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON \
      -DBOOST_ROOT=$PREFIX \
      -DBoost_NO_SYSTEM_PATHS=ON \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DBoost_DEBUG=ON \
      -DUSE_EXTERNAL_TINYXML=ON \
      -DUSE_INTERNAL_URDF=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=ON

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
ctest -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION"
