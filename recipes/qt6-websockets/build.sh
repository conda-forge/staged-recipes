#!/bin/sh

mkdir build && cd build
cmake -LAH ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DINSTALL_BINDIR=lib/qt6/bin \
  -DINSTALL_PUBLICBINDIR=usr/bin \
  -DINSTALL_LIBEXECDIR=lib/qt6 \
  -DINSTALL_DOCDIR=share/doc/qt6 \
  -DINSTALL_ARCHDATADIR=lib/qt6 \
  -DINSTALL_DATADIR=share/qt6 \
  -DINSTALL_INCLUDEDIR=include/qt6 \
  -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs \
  -DINSTALL_EXAMPLESDIR=share/doc/qt6/examples \
  -DFEATURE_framework=OFF \
  ..
make install -j${CPU_COUNT}

