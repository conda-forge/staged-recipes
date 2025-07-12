#!/usr/bin/env bash


mkdir build
cd build

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

export CFLAGS="${CFLAGS} -I ${PREFIX}/include/eigen3"
export CXXFLAGS="${CXXFLAGS} -I ${PREFIX}/include/eigen3"


cmake  $CMAKE_ARGS ../greedy \
      -DITK_DIR="${PREFIX}/lib/cmake/ITK" \
      -DCMAKE_BUILD_TYPE=Release \
      -DUSE_FFTW=OFF \
      -DEigen3_DIR="${PREFIX}/include/eigen3" \
      -DVTK_DIR="${PREFIX}/include/vtk-9.3" \
      ..

make -j$CPU_COUNT

make install