#!/usr/bin/env bash

# A dummy greedy repo is cloned because CMakeLists.txt requires
# .git dir

# Clone the repository into a temporary directory
git clone https://github.com/pyushkevich/greedy /tmp/greedy

# Change to the directory where the source is located
cd /tmp/greedy

mkdir build
cd build

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

export CFLAGS="${CFLAGS} -I ${PREFIX}/include/eigen3"
export CXXFLAGS="${CXXFLAGS} -I ${PREFIX}/include/eigen3"


cmake  ../greedy \
      -DITK_DIR="${CONDA_PREFIX}/lib/cmake/ITK" \
      -DCMAKE_BUILD_TYPE=Release \
      -DUSE_FFTW=OFF \
      -DEigen3_DIR="${CONDA_PREFIX}/include/eigen3" \
      -DVTK_DIR="${CONDA_PREFIX}/include/vtk-9.3" \
      ..

make