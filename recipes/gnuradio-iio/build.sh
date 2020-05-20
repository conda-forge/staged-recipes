#!/bin/bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DBoost_NO_BOOST_CMAKE=ON
    -DGR_PYTHON_DIR=`$PYTHON -c "import site; print(site.getsitepackages()[0])"`
    -DENABLE_DOXYGEN=OFF
)

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
