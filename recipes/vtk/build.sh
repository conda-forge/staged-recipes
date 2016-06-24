#!/bin/bash
mkdir build
cd build

BUILD_CONFIG=Release

# sometimes python is suffixed, this is a quick fix
# in a future PR we should probably switch to cmake find python scripting
PYTHON_INCLUDE=${PREFIX}/include/python${PY_VER}
if [ ! -d $PYTHON_INCLUDE ]; then
  PYTHON_INCLUDE=${PREFIX}/include/python${PY_VER}m
fi

PYTHON_LIBRARY="libpython${PY_VER}.so"
PYTHON_LIBRARY=${PREFIX}/lib/${PYTHON_LIBRARY}
if [ ! -f $PYTHON_LIBRARY ]; then
    PYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}m.so
fi

cmake .. -G "Unix Makefiles" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DINSTALL_PKGCONFIG_DIR:PATH=$PKG_CONFIG_PATH \
    -DBUILD_DOCUMENTATION:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_ENABLE_VTKPYTHON:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PY_VER}" \
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="${SP_DIR}" \
    -DModule_vtkWrappingPythonCore:BOOL=OFF \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE \
    -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY
        
make install
