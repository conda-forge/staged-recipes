#!/usr/bin/env bash

# A workaround until the scikit-commpy package is on conda-forge
echo "Entering gr-gfdm build.sh ..."
echo "Installing dependency scikit-commpy ..."
# pip install --no-deps scikit-commpy
cd commpy
pip install --no-deps .
cd ..
echo "Finished installing scikit-commpy. Proceeding to gr-gfdm ..."
cd gr-gfdm
mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_PREFIX_PATH=$PREFIX
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DENABLE_DOXYGEN=OFF
)

cmake ${CMAKE_ARGS} -G "Ninja" "${cmake_config_args[@]}" ..
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --target install
