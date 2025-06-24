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

