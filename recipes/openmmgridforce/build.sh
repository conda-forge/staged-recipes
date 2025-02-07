#!/bin/bash

mkdir build
cd build

# Set platform-specific flags
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific settings
    CMAKE_EXTRA_ARGS="-DCMAKE_INSTALL_NAME_DIR=$PREFIX/lib -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"
else
    # Linux settings
    CMAKE_EXTRA_ARGS=""
fi

# Configure build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DOPENMM_DIR=$PREFIX \
    ${CMAKE_EXTRA_ARGS}

# Build in parallel
make -j$CPU_COUNT
make install
make check

# Build Python wrappers
cd ../python

# Replace template variables in setup.py
sed -i.bak "s|@OPENMM_DIR@|$PREFIX|g" setup.py
sed -i.bak "s|@GRIDFORCEPLUGIN_HEADER_DIR@|$PREFIX/include|g" setup.py
sed -i.bak "s|@GRIDFORCEPLUGIN_LIBRARY_DIR@|$PREFIX/lib|g" setup.py

swig -python -c++ -o GridForcePluginWrapper.cpp -I$PREFIX/include gridforceplugin.i
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
