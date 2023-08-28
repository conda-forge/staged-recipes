#!/bin/bash

mkdir build
cd build

export TFELHOME="${PREFIX}"
python_version="${CONDA_PY:0:1}.${CONDA_PY:1:2}"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -Denable-c-bindings=OFF \
    -Denable-fortran-bindings=OFF \
    -Denable-python-bindings=ON \
    -Denable-portable-build=ON \
    -Denable-julia-bindings=OFF \
    -Denable-website=OFF \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -DPYTHONLIBS_VERSION_STRING="${CONDA_PY}" \
    -DPython_ADDITIONAL_VERSIONS="${python_version}" \
    -DPYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
    -DPYTHON_LIBRARY:FILEPATH="${PREFIX}/lib/libpython${python_version}.so" \
    -DPYTHON_LIBRARY_PATH:PATH="${PREFIX}/lib" \
    -DPYTHON_INCLUDE_DIRS:PATH="${PREFIX}/include" \
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON \
    ${CMAKE_PLATFORM_FLAGS[@]} \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"

make
make install