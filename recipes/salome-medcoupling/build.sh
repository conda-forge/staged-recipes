#!/bin/sh

git clone --depth 1 -b V9_11_0 https://git.salome-platform.org/gitpub/tools/configuration.git ${SRC_DIR}/configuration

git clone --depth 1 -b V9_11_0 https://git.salome-platform.org/gitpub/tools/medcoupling.git && cd medcoupling

mkdir build && cd build

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=NEVER \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER} \
  -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}${SHLIB_EXT} \
  -DMEDCOUPLING_BUILD_DOC=OFF \
  -DMEDCOUPLING_BUILD_TESTS=OFF \
  -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
  -DMEDCOUPLING_USE_64BIT_IDS=OFF \
  -DCONFIGURATION_ROOT_DIR=${SRC_DIR}/configuration \
  ..
cmake --build . --target install
rm -rf ${SP_SIR}/__pycache__
