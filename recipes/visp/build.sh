#!/bin/sh

set -ex

export OGRE_DIR="${PREFIX}/lib/OGRE/cmake"

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_MODULE_visp_ar=ON \
      -DBUILD_MODULE_visp_blob=ON \
      -DBUILD_MODULE_visp_core=ON \
      -DBUILD_MODULE_visp_detection=ON \
      -DBUILD_MODULE_visp_gui=ON \
      -DBUILD_MODULE_visp_imgproc=ON \
      -DBUILD_MODULE_visp_io=ON \
      -DBUILD_MODULE_visp_klt=ON \
      -DBUILD_MODULE_visp_mbt=ON \
      -DBUILD_MODULE_visp_me=ON \
      -DBUILD_MODULE_visp_robot=ON \
      -DBUILD_MODULE_visp_sensor=ON \
      -DBUILD_MODULE_visp_tt=ON \
      -DBUILD_MODULE_visp_tt_mi=ON \
      -DBUILD_MODULE_visp_vision=ON \
      -DBUILD_MODULE_visp_visual_features=ON \
      -DBUILD_MODULE_visp_vs=ON \
      -DUSE_OPENMP=ON \
      -DUSE_PTHREAD=ON \
      -DWITH_LAPACK=OFF \
      -DBUILD_TESTS=ON

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose