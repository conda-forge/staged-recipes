#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} \
  -B build \
  -S . \
  -G Ninja \
  -DPLUGIN_SOFAGLFW:BOOL=ON \
  -DPLUGIN_SOFAIMGUI:BOOL=ON \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DPython_EXECUTABLE:PATH=${PREFIX}/bin/python \
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH=python${PY_VER}/site-packages

# build
cmake --build build --parallel ${CPU_COUNT}

# install
cmake --install build

# testing compilation as 3rd party
if [[ $CONDA_BUILD_CROSS_COMPILATION != 1 ]]; then
  cmake ${CMAKE_ARGS} \
    -B build-test \
    -S SofaImGui/extensions/SofaImGui.Camera \
    -G Ninja

  cmake --build build-test --parallel ${CPU_COUNT}
fi