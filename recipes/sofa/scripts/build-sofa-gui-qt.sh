#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

rm -rf build-sofa-gui-qt

mkdir build-sofa-gui-qt
cd build-sofa-gui-qt

cmake ${CMAKE_ARGS} \
  -B . \
  -S ../Sofa/GUI/Qt \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DSOFA_ALLOW_FETCH_DEPENDENCIES:BOOL=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install
