#!/bin/sh

mkdir -p build && cd build

# needs qt5 for imageio
cmake \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DWITH_CGAL_ImageIO=OFF -DWITH_CGAL_Qt5=OFF \
  ..

make install


# language bindings are in a separate repo without releases
git clone https://github.com/CGAL/cgal-swig-bindings.git
cd cgal-swig-bindings
mkdir -p build && cd build

cmake \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPYTHON_OUTDIR_PREFIX=${SP_DIR} \
  -DCOMMON_LIBRARIES_PATH=${PREFIX}/lib \
  -DBUILD_JAVA=OFF \
  ..
make

rm ${SP_DIR}/CGAL/*PYTHON_wrap.cxx
