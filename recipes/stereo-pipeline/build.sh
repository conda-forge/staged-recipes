#!/bin/bash

# Architecture-dependent flags
if [ "$(uname)" = "Darwin" ]; then
    LIB_FLAG='-dynamiclib'
else
    LIB_FLAG='-shared'
fi

# Build dependencies first

# fgr
cd $SRC_DIR/FastGlobalRegistration
FGR_SOURCE_DIR=$(pwd)/source
mkdir -p build && cd build
cmake                                                                           \
  ${CMAKE_ARGS}                                                                 \
  -DCMAKE_BUILD_TYPE=Release                                                    \
  -DCMAKE_CXX_FLAGS="-I${PREFIX}/include -I${PREFIX}/include/eigen3 -std=c++11" \
  -DCMAKE_EXE_LINKER_FLAGS="-L${PREFIX}/lib -lflann_cpp"                        \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${PREFIX}/lib -lflann_cpp -llz4                \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}                                         \
  -DCMAKE_VERBOSE_MAKEFILE=ON                                                   \
  -DFastGlobalRegistration_LINK_MODE=SHARED                                     \
  ${FGR_SOURCE_DIR}
make -j${CPU_COUNT}
# Install
FGR_INC_DIR=${PREFIX}/include/FastGlobalRegistration
mkdir -p ${FGR_INC_DIR}
cp ${FGR_SOURCE_DIR}/FastGlobalRegistration/app.h ${FGR_INC_DIR}
FGR_LIB_DIR=${PREFIX}/lib
mkdir -p ${FGR_LIB_DIR}
cp FastGlobalRegistration/libFastGlobalRegistrationLib* ${FGR_LIB_DIR}

# Multiview
cd $SRC_DIR/MultiView
mkdir -p build && cd build
cmake ${CMAKE_ARGS} ..             \
    -DCMAKE_BUILD_TYPE=Release     \
    -DMULTIVIEW_DEPS_DIR=${PREFIX} \
    -DCMAKE_VERBOSE_MAKEFILE=ON    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}
make -j${CPU_COUNT} install

# Geoid
cd $SRC_DIR/geoids
# Build
${FC} ${FFLAGS} -fPIC -O3 -c interp_2p5min.f
${FC} ${LDFLAGS} ${LIB_FLAG} -o libegm2008${SHLIB_EXT} interp_2p5min.o
# Install
mkdir -p ${PREFIX}/lib
cp libegm2008.* ${PREFIX}/lib
GEOID_DIR=${PREFIX}/share/geoids
mkdir -p ${GEOID_DIR}
cp *.tif *.jp2 ${GEOID_DIR}

# libnabo
cd $SRC_DIR/libnabo
mkdir -p build && cd build
cmake                                          \
  ${CMAKE_ARGS}                                \
  -DCMAKE_BUILD_TYPE=Release                   \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
  -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 \
  -DBUILD_SHARED_LIBS=ON                       \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  ..
make -j${CPU_COUNT} install

# libpointmatcher
cd $SRC_DIR/libpointmatcher
mkdir -p build && cd build
cmake                                          \
  ${CMAKE_ARGS}                                \
  -DCMAKE_BUILD_TYPE=Release                   \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  -DBUILD_SHARED_LIBS=ON                       \
  -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 \
  ..
make -j${CPU_COUNT} install

# s2p
cd $SRC_DIR/s2p
baseDir=$(pwd)
export CFLAGS="-I$PREFIX/include -O3 -DNDEBUG -march=native"
export LDFLAGS="-L$PREFIX/lib"
# Build the desired programs
cd 3rdparty/mgm
perl -pi -e "s#CFLAGS=#CFLAGS=$CFLAGS #g" Makefile
perl -pi -e "s#LDFLAGS=#LDFLAGS=$LDFLAGS #g" Makefile 
make -j${CPU_COUNT}
cd $baseDir
# msmw
cd 3rdparty/msmw
mkdir -p build
cd build
cmake ..                                                       \
    ${CMAKE_ARGS}                                              \
    -DPNG_LIBRARY_RELEASE="${PREFIX}/lib/libpng${SHLIB_EXT}"   \
    -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${SHLIB_EXT}" \
    -DZLIB_LIBRARY_RELEASE="${PREFIX}/lib/libz${SHLIB_EXT}"    \
    -DJPEG_LIBRARY="${PREFIX}/lib/libjpeg${SHLIB_EXT}"
make -j${CPU_COUNT}
cd $baseDir
# msmw2
cd 3rdparty/msmw2
mkdir -p build
cd build
cmake ..                                                       \
    ${CMAKE_ARGS}                                              \
    -DPNG_LIBRARY_RELEASE="${PREFIX}/lib/libpng${SHLIB_EXT}"   \
    -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${SHLIB_EXT}" \
    -DZLIB_LIBRARY_RELEASE="${PREFIX}/lib/libz${SHLIB_EXT}"    \
    -DJPEG_LIBRARY="${PREFIX}/lib/libjpeg${SHLIB_EXT}"
make -j${CPU_COUNT}
cd $baseDir
# Install the desired programs
BIN_DIR=${PREFIX}/plugins/stereo/mgm/bin
mkdir -p ${BIN_DIR}
cp 3rdparty/mgm/mgm ${BIN_DIR}
BIN_DIR=${PREFIX}/plugins/stereo/msmw/bin
mkdir -p ${BIN_DIR}
cp 3rdparty/msmw/build/libstereo/iip_stereo_correlation_multi_win2 \
   ${BIN_DIR}/msmw
BIN_DIR=${PREFIX}/plugins/stereo/msmw2/bin
mkdir -p ${BIN_DIR}
cp 3rdparty/msmw2/build/libstereo_newversion/iip_stereo_correlation_multi_win2_newversion \
   ${BIN_DIR}/msmw2

# libelas
if [[ "$target_platform" == *aarch64* || "$target_platform" == *arm64* ]]; then
    echo libelas does not build on Arm
else
    cd $SRC_DIR/libelas
    # build
    mkdir -p build
    cd build
    cmake ..                                                      \
        ${CMAKE_ARGS}                                             \
        -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${SHLIB_EXT}"
    make -j${CPU_COUNT}
    # Copy the 'elas' tool to the plugins subdir meant for it
    BIN_DIR=${PREFIX}/plugins/stereo/elas/bin
    mkdir -p ${BIN_DIR}
    cp elas ${BIN_DIR}/elas
fi

# Build stereo-pipeline
cd $SRC_DIR/StereoPipeline
mkdir -p build
cd build
cmake ..                             \
    ${CMAKE_ARGS}                    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DUSE_ISIS=OFF                   \
    -DUSE_OPENEXR=OFF                \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT} install
