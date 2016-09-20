#!/usr/bin/env bash

# NOTES:
# src/app/main.cpp has specific logic for handling QT_PLUGIN_PATH on
# win/osx but not linux. See ticket from homebrew-osgeo4mac for
# related information
# https://github.com/OSGeo/homebrew-osgeo4mac/issues/27
#
# Installation instructions:
#   https://github.com/qgis/QGIS/blob/master/INSTALL
# Prior art:
#   https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=qgis

# BUILD
[[ -d build ]] || mkdir build
cd build/

# Defining these allows QGIS cmake files to find most of the libraries
export CMAKE_PREFIX_PATH=${PREFIX}
export CMAKE_PREFIX=${PREFIX}

cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_TESTS=FALSE \
    -DPYTHON_EXECUTABLE:PATH=${PYTHON} \
    -DWITH_PYSPATIALITE:BOOL=ON \
    -DWITH_QSPATIALITE:BOOL=ON \
    -DEXPAT_INCLUDE_DIR=$PREFIX/include \
    -DEXPAT_LIBRARY=$PREFIX/lib/libexpat.so \
    -DWITH_INTERNAL_{HTTPLIB2,JINJA2,MARKUPSAFE,OWSLIB,PYGMENTS,DATEUTIL,PYTZ,YAML,NOSE2,SIX,FUTURE}=FALSE

make
# no make check
make install

