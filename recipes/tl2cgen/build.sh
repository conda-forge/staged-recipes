#!/bin/bash

set -x
set -e

mkdir build
cd build
cmake ${CMAKE_ARGS} .. -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_INSTALL_LIBDIR="lib" -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_AVAILABILITY" -DCMAKE_BUILD_TYPE=Release -DBUILD_CPP_TESTS=ON -GNinja
ninja
ctest -V
ninja install   # Install libtl2cgen.so into Conda env
cd ../python
# Set use_system_libtl2cgen=True so that only one copy of libtl2cgen.so is installed in the Conda env
${PYTHON} -m pip install -v . --config-settings use_system_libtl2cgen=True
