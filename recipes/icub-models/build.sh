#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON \
      -DPython3_EXECUTABLE:PATH=$PYTHON \
      -DICUB_MODELS_COMPILE_PYTHON_BINDINGS:BOOL=ON \
      -DICUB_MODELS_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON \
      -DICUB_MODELS_PYTHON_PIP_METADATA_INSTALL:BOOL=ON \
      -DICUB_MODELS_PYTHON_PIP_METADATA_INSTALLER=conda

cmake --build . --config Release
cmake --build . --config Release --target install
ctest --output-on-failure -C Release
