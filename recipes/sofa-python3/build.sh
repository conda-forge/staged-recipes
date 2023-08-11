#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

# We have to manually set the Rpath for Python packages to the lib/ directory using
# the CMAKE_INSTALL_RPATH cmake variable.
cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib \
  -DPython_EXECUTABLE:PATH=${PREFIX}/bin/python \
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH=python${PY_VER}/site-packages \
  -DSP3_BUILD_TEST:BOOL=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# test
ctest --parallel ${CPU_COUNT}