#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

# Set CMAKE_INSTALL_RPATH_USE_LINK_PATH is necessary to link to libCollisionOBBCapsule
# which installs to the non-standard location $PREFIX/plugins/CollisionOBBCapsule/lib
cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DPython_EXECUTABLE:PATH=${PREFIX}/bin/python \
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH=python${PY_VER}/site-packages \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON \
  -DMODELORDERREDUCTION_BUILD_TESTS:BOOL=ON

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# test
ctest --parallel ${CPU_COUNT}