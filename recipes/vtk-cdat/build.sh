#!/bin/bash

mkdir build
cd build || exit

BUILD_CONFIG=Release
OSNAME=$(uname)

# Use bash "Remove Largest Suffix Pattern" to get rid of all but major version number
PYTHON_MAJOR_VERSION=${PY_VER%%.*}

# These will help cmake find the right python
PYTHON_H_FILE=$(find "$PREFIX" -name Python.h -type f)
PYTHON_INCLUDE_DIR=$(dirname "${PYTHON_H_FILE}")
if [ "${OSNAME}" == Darwin ]; then
    PYTHON_LIBRARY=$(find "$PREFIX/lib" -regex '.*libpython.*\..*\.dylib$')
elif [ "${OSNAME}" == Linux ]; then
    PYTHON_LIBRARY=$(find "$PREFIX/lib" -regex '.*libpython.*\..*\.so$')
fi
PYTHON_INCLUDE_PARAMETER_NAME="Python${PYTHON_MAJOR_VERSION}_INCLUDE_DIR"
PYTHON_LIBRARY_PARAMETER_NAME="Python${PYTHON_MAJOR_VERSION}_LIBRARY_RELEASE"

echo "\n\nXXX XXX XXX BUILD_PREFIX: $BUILD_PREFIX XXX XXX XXX\n"
echo "\n\nXXX XXX XXX CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT XXX XXX XXX\n"

#if [ "${OSNAME}" == Darwin ]; then
#    CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk
#fi

if [ -f "$PREFIX/lib/libOSMesa32${SHLIB_EXT}" ]; then
    VTK_ARGS="${VTK_ARGS} \
        -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=ON \
        -DVTK_OPENGL_HAS_OSMESA:BOOL=ON \
        -DOSMESA_INCLUDE_DIR:PATH=${PREFIX}/include \
        -DOSMESA_LIBRARY:FILEPATH=${PREFIX}/lib/libOSMesa32${SHLIB_EXT}"

    if [ "${OSNAME}" == Linux ]; then
        VTK_ARGS="${VTK_ARGS} \
            -DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake
            -DVTK_USE_X:BOOL=OFF"
    elif [ "${OSNAME}" == Darwin ]; then
        VTK_ARGS="${VTK_ARGS} \
            -DVTK_USE_COCOA:BOOL=OFF \
            -DCMAKE_OSX_SYSROOT:PATH=${CONDA_BUILD_SYSROOT}"
    fi
else
    VTK_ARGS="${VTK_ARGS} \
        -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=OFF \
        -DVTK_OPENGL_HAS_OSMESA:BOOL=OFF"
    if [ "${OSNAME}" == Linux ]; then
        VTK_ARGS="${VTK_ARGS} \
            -DVTK_USE_X:BOOL=ON \
            -DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake
            -DOPENGL_gl_LIBRARY:FILEPATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so
            -DX11_Xt_LIB:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libXt.so
            -DX11_SM_LIB:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libSM.so
            -DX11_ICE_LIB:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libICE.so
            -DX11_X11_LIB:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libX11.so"
    elif [ "${OSNAME}" == Darwin ]; then
        VTK_ARGS="${VTK_ARGS} \
            -DVTK_USE_COCOA:BOOL=ON \
            -DCMAKE_OSX_SYSROOT:PATH=${CONDA_BUILD_SYSROOT}"
    fi
fi

# now we can start configuring
cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR:PATH="lib" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DVTK_BUILD_DOCUMENTATION:BOOL=OFF \
    -DVTK_BUILD_TESTING:STRING=OFF \
    -DVTK_BUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_LEGACY_SILENT:BOOL=OFF \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PYTHON_MAJOR_VERSION}" \
    "-D${PYTHON_INCLUDE_PARAMETER_NAME}:PATH=${PYTHON_INCLUDE_DIR}" \
    "-D${PYTHON_LIBRARY_PARAMETER_NAME}:FILEPATH=${PYTHON_LIBRARY}" \
    -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
    -DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_PythonContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES \
    ${VTK_ARGS}     # we need word spliting here

# compile and install
ninja install
