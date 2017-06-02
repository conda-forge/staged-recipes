#!/bin/bash

mkdir build
cd build

if [ `uname` == Linux ]; then
    # use globs to take into account all possible suffixes: m, u, d
    PY_LIB=`ls "${PREFIX}/lib/libpython${PY_VER}"*.so | head -n 1`
    PY_INC=`ls -d "${PREFIX}/include/python${PY_VER}"* | head -n 1`

    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_INSTALL_RPATH:STRING="${PREFIX}/lib" \
        -DBUILD_DOCUMENTATION=OFF \
        -DVTK_HAS_FEENABLEEXCEPT=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DVTK_WRAP_PYTHON=ON \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_INCLUDE_PATH=${PY_INC} \
        -DPYTHON_LIBRARY=${PY_LIB} \
        -DVTK_INSTALL_PYTHON_MODULE_DIR=${SP_DIR} \
        -DModule_vtkRenderingMatplotlib=ON \
        -DVTK_USE_X=ON \
        -DVTK_PYTHON_VERSION=${PY_VER:0:1}
fi

if [ `uname` == Darwin ]; then
    # use globs to take into account all possible suffixes: m, u, d
    PY_LIB=`ls "${PREFIX}/lib/libpython${PY_VER}"*.dylib | head -n 1`
    PY_INC=`ls -d "${PREFIX}/include/python${PY_VER}"* | head -n 1`
    MACOSX_DEPLOYMENT_TARGET=10.7

    cmake .. \
        -DVTK_REQUIRED_OBJCXX_FLAGS='' \
        -DVTK_USE_TK=OFF \
        -DVTK_USE_COCOA=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_INSTALL_RPATH:STRING="$PREFIX/lib" \
        -DBUILD_DOCUMENTATION=OFF \
        -DVTK_HAS_FEENABLEEXCEPT=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DVTK_WRAP_PYTHON=ON \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_INCLUDE_PATH=${PY_INC} \
        -DPYTHON_LIBRARY=${PY_LIB} \
        -DVTK_INSTALL_PYTHON_MODULE_DIR=${SP_DIR} \
        -DModule_vtkRenderingMatplotlib=ON \
        -DVTK_USE_X=OFF \
        -DVTK_PYTHON_VERSION=${PY_VER:0:1}
fi

make -j${CPU_COUNT}
make install
