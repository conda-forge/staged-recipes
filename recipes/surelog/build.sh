#! /bin/bash

set -e
set -x

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=ON -DSURELOG_USE_HOST_FLATBUFFERS=ON -DSURELOG_USE_HOST_ANTLR=ON -DSURELOG_USE_HOST_UHDM=ON -DSURELOG_USE_HOST_GTEST=ON -DSURELOG_WITH_TCMALLOC=OFF -DPYTHON_EXECUTABLE="$PYTHON" -DPython3_EXECUTABLE="$PYTHON" -DCMAKE_FIND_FRAMEWORK=NEVER
cmake --build build --config Release
cmake --install build --config Release
