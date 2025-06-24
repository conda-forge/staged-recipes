#!/bin/bash

# Build dependencies first

# Geoid
cd $SRC_DIR/geoids/geoids
if [ "$(uname)" = "Darwin" ]; then
    LIB_FLAG='-dynamiclib'
    EXT='.dylib'
else
    LIB_FLAG='-shared'
    EXT='.so'
fi
# Build
${FC} ${FFLAGS} -fPIC -O3 -c interp_2p5min.f
${FC} ${LDFLAGS} ${LIB_FLAG} -o libegm2008${EXT} interp_2p5min.o
# Install
mkdir -p ${PREFIX}/lib
/bin/cp -fv libegm2008.* ${PREFIX}/lib
GEOID_DIR=${PREFIX}/share/geoids
mkdir -p ${GEOID_DIR}
/bin/cp -fv *tif *jp2 ${GEOID_DIR}

# libnabo
cd $SRC_DIR/libnabo/libnabo
mkdir -p build && cd build
cmake                                          \
  -DCMAKE_BUILD_TYPE=Release                   \
  -DCMAKE_CXX_FLAGS='-O3 -std=c++11'           \
  -DCMAKE_C_FLAGS='-O3'                        \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
  -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 \
  -DCMAKE_PREFIX_PATH=${PREFIX}                \
  -DBoost_DIR=${PREFIX}/lib                    \
  -DBoost_INCLUDE_DIR=${PREFIX}/include        \
  -DBUILD_SHARED_LIBS=ON                       \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  ..
make -j${CPU_COUNT} install

# libpointmatcher
cd $SRC_DIR/libpointmatcher/libpointmatcher
mkdir -p build && cd build
cmake                                          \
  -DCMAKE_BUILD_TYPE=Release                   \
  -DCMAKE_CXX_FLAGS="-O3 -std=c++17"           \
  -DCMAKE_C_FLAGS='-O3'                        \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  -DCMAKE_PREFIX_PATH=${PREFIX}                \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  -DBUILD_SHARED_LIBS=ON                       \
  -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 \
  -DBoost_DIR=${PREFIX}/lib                    \
  -DBoost_INCLUDE_DIR=${PREFIX}/include        \
  -DBoost_NO_BOOST_CMAKE=OFF                   \
  -DBoost_DEBUG=ON                             \
  -DBoost_DETAILED_FAILURE_MSG=ON              \
  -DBoost_NO_SYSTEM_PATHS=ON                   \
  ..
make -j${CPU_COUNT} install

# # This is for later
# mkdir build && cd build
# cmake ${SRC_DIR}                             \
#     -DCMAKE_PREFIX_PATH=${PREFIX}    \
#     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#     -DASP_DEPS_DIR=${PREFIX}         \
#     -DUSE_OPENEXR=OFF                \
#     -DCMAKE_VERBOSE_MAKEFILE=ON
# make -j${CPU_COUNT}
# make install

