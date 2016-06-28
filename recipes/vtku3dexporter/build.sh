#!/usr/bin/env bash
BUILD_CONFIG=Release

cd Samples/SampleCode

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
    -DWRAP_PYTHON:BOOL=ON \
    -DINSTALL_PYTHON_MODULE_DIR:PATH="${SP_DIR}" \
    -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE \
    -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY

make install
