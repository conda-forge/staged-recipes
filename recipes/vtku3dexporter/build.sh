#!/usr/bin/env bash
BUILD_CONFIG=Release

cd Samples/SampleCode

mkdir build
cd build

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

cmake .. -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PY_VER}" \
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="${SP_DIR}" \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE \
    -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY

make install
