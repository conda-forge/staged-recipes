#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DPython_EXECUTABLE:PATH=${PREFIX}/bin/python \
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH=python${PY_VER}/site-packages \
  -DMODELORDERREDUCTION_BUILD_TESTS:BOOL=ON

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# test
ctest --parallel ${CPU_COUNT}