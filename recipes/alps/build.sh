#!/usr/bin/env bash

set -e

function python_finder {
  python_library="-DPYTHON_LIBRARY="
  python_include="-DPYTHON_INCLUDE_DIR="

  # ALPS FindPython.cmake relies on distutils.sysconfig which however does not work properly.
  python_prefix=$(python-config --prefix | sed 's/^[ \t]*//')
  if [ -f "${python_prefix}/Python" ]; then
    python_library+="${python_prefix}/Python"
    python_include+="${python_prefix}/Headers"
  else
    which_python=$(python -c 'import sys;print(sys.version)' | sed 's/^[ \t]*//')
    which_python="python${which_python:0:3}"
    lib_python="${python_prefix}/lib/lib${which_python}"
    if [ -f "${lib_python}.a" ]; then
      python_library+="${lib_python}.a"
    else
      python_library+="${lib_python}.dylib"
    fi
    python_include+="${python_prefix}/include/${which_python}"
  fi

  echo "${python_library} ${python_include}"
}

function num_cores {
  num_cpus=1
  if [[ `uname -s` == "Linux" ]]; then
    num_cpus=$CPU_COUNT
  else
    num_cpus=$(sysctl -n hw.ncpu)
  fi
  echo $num_cpus
}

function cxx_flags {
  if [[ `uname -s` == "Darwin" ]]; then
    echo "-std=c++11 -stdlib=libc++"
  else
    echo "-std=c++11"
  fi
}



mkdir build && cd build
## CMake config
cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_GENERATOR="$CMAKE_GENERATOR" \
  -DCMAKE_CXX_FLAGS="$(cxx_flags)" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET" \
  -DALPS_ENABLE_MPI=OFF \
  -DALPS_BUILD_APPLICATIONS=OFF \
  -DALPS_BUILD_EXAMPLES=OFF \
  -DBOOST_ROOT=$PREFIX \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DPYTHON_INTERPRETER=$PYTHON \
  -DPYTHON_FOUND=TRUE $(python_finder) \
  -DPYTHON_NUMPY_INCLUDE_DIR=$SP_DIR/numpy/core/include \
  ..

##Build
make -j $(num_cores)
## Test
ctest --output-on-failure
## Install
make install
## Install pyalps to correct path
mv $PREFIX/lib/pyalps $SP_DIR/pyalps

