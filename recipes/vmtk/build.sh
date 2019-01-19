#!/bin/sh

## Program:   VMTK
## Module:    Anaconda Distribution
## Language:  Python
## Date:      January 30, 2018
##
##   Copyright (c) Richard Izzo, Luca Antiga, David Steinman. All rights reserved.
##   See LICENCE file for details.
##      This software is distributed WITHOUT ANY WARRANTY; without even
##      the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
##      PURPOSE.  See the above copyright notices for more information.
##
## Note: this script was contributed by
##       Richard Izzo (Github @rlizzo)
##       University at Buffalo
##
## This file contains the packaging and distribution shell script data for packaging
## VMTK via the Continuum Analytics Anaconda Python distribution.
## See https://www.continuum.io/ for distribution info

mkdir build
cd ./build

if [[ $PY3K -eq 1 || $PY3K == "True" ]]; then
  export PY_STR="${PY_VER}m"
else
  export PY_STR="${PY_VER}"
fi


if [ `uname` = "Darwin" ]; then
    cmake .. -LAH -G "Ninja" \
    -Wno-dev \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="10.9" \
    -DCMAKE_OSX_SYSROOT="$HOME/MacOSX-SDKs/MacOSX10.9.sdk" \
    -DVMTK_BUILD_TESTING:BOOL=ON \
    -DSUPERBUILD_INSTALL_PREFIX:STRING=${PREFIX} \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DVTK_LEGACY_SILENT:BOOL=ON \
    -DITK_LEGACY_SILENT:BOOL=ON \
    -DVTK_VMTK_USE_COCOA:BOOL=ON \
    -DVMTK_RENDERING_BACKEND:STRING="OpenGL2" \
    -DUSE_SYSTEM_VTK:BOOL=ON \
    -DUSE_SYSTEM_ITK:BOOL=ON \
    -DPYTHON_EXECUTABLE="$PYTHON" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DVMTK_MODULE_INSTALL_LIB_DIR="$PREFIX"/vmtk \
    -DINSTALL_PKGCONFIG_DIR="$PREFIX"/lib/pkgconfig \
    -DVMTK_BREW_PYTHON:BOOL=OFF \
    -DVMTK_USE_RENDERING:BOOL=ON \
    -DVTK_VMTK_CONTRIB:BOOL=ON \
    -DVMTK_CONTRIB_SCRIPTS:BOOL=ON \
    -DVMTK_USE_SUPERBUILD:BOOL=OFF \
    -DVMTK_PYTHON_VERSION:STRING="python${PY_VER}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_CXX_EXTENSIONS=OFF

    ninja install
fi

if [ `uname` = "Linux" ]; then
    cmake .. -LAH -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DUSE_SYSTEM_VTK:BOOL=ON \
    -DUSE_SYSTEM_ITK:BOOL=ON \
    -DVMTK_BUILD_TESTING:BOOL=ON \
    -DSUPERBUILD_INSTALL_PREFIX:STRING=${PREFIX} \
    -DPYTHON_EXECUTABLE:STRING=${PYTHON} \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -DVMTK_MODULE_INSTALL_LIB_DIR:STRING="${PREFIX}/vmtk" \
    -DINSTALL_PKGCONFIG_DIR:STRING="${PREFIX}/lib/pkgconfig" \
    -DGIT_PROTOCOL_HTTPS:BOOL=ON \
    -DVMTK_USE_RENDERING:BOOL=ON \
    -DVTK_VMTK_CONTRIB:BOOL=ON \
    -DVMTK_CONTRIB_SCRIPTS:BOOL=ON \
    -DVMTK_USE_SUPERBUILD:BOOL=OFF \
    -DVMTK_PYTHON_VERSION:STRING="python${PY_VER}" \
    -DITK_LEGACY_SILENT:BOOL=ON \
    -DVTK_LEGACY_SILENT:BOOL=ON \
    -DCMAKE_CXX_STANDARD=11 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_CXX_EXTENSIONS=OFF

    ninja install 
fi
