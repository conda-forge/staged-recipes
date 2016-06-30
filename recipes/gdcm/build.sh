#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

mkdir build
cd build

BUILD_CONFIG=Release

# sometimes python is suffixed, these are quick fixes
# in a future PR we should probably switch to cmake find python scripting

PYTHON_INCLUDE="${PREFIX}/include/python${PY_VER}"
if [ ! -d $PYTHON_INCLUDE ]; then
    PYTHON_INCLUDE="${PREFIX}/include/python${PY_VER}m"
fi

PYTHON_LIBRARY_EXT="so"
if [ `uname` = "Darwin" ] ; then
    PYTHON_LIBRARY_EXT="dylib"
fi

PYTHON_LIBRARY="${PREFIX}/lib/libpython${PY_VER}.${PYTHON_LIBRARY_EXT}"
if [ ! -f $PYTHON_LIBRARY ]; then
    PYTHON_LIBRARY="${PREFIX}/lib/libpython${PY_VER}m.${PYTHON_LIBRARY_EXT}"
fi

# end of quick fixes

cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DCMAKE_INSTALL_RPATH:PATH="$PREFIX/lib" \
    -DGDCM_BUILD_SHARED_LIBS:BOOL=ON \
    -DGDCM_BUILD_APPLICATIONS:BOOL=ON \
    -DGDCM_BUILD_TESTING:BOOL=OFF \
    -DGDCM_BUILD_EXAMPLES:BOOL=OFF \
    -DGDCM_BUILD_APPLICATIONS=OFF \
    -DGDCM_USE_VTK:BOOL=OFF \
    -DGDCM_WRAP_PYTHON:BOOL=ON \
    -DGDCM_DOCUMENTATION:BOOL=OFF \
    -DSWIG_EXECUTABLE:FILEPATH=$PREFIX/bin/swig \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE \
    -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY \
    -DGDCM_INSTALL_PYTHONMODULE_DIR:PATH=$SP_DIR \
    -DGDCM_INSTALL_NO_DOCUMENTATION:BOOL=ON \
    -DGDCM_INSTALL_NO_DEVELOPMENT:BOOL=ON

ninja install
