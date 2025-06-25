#!/bin/bash

# Architecture-dependent flags
if [ "$(uname)" = "Darwin" ]; then
    LIB_FLAG='-dynamiclib'
    EXT='.dylib'
    deployFlag="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"
else
    LIB_FLAG='-shared'
    EXT='.so'
    deployFlag=""
fi

# Build dependencies first

# Multiview
cd $SRC_DIR/MultiView
mkdir -p build && cd build
CMAKE_ARGS+=("-DCMAKE_PREFIX_PATH=${PREFIX}")
cmake ..                                                              \
    -DCMAKE_BUILD_TYPE=Release                                        \
    -DMULTIVIEW_DEPS_DIR=${PREFIX}                                    \
    -DCMAKE_VERBOSE_MAKEFILE=ON                                       \
    -DCMAKE_CXX_FLAGS="-O3 -std=c++11 -Wno-error -I${PREFIX}/include" \
    -DCMAKE_C_FLAGS='-O3 -Wno-error'                                  \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                  \
    $deployFlag
make -j${CPU_COUNT} install

# Geoid
cd $SRC_DIR/geoids
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
cd $SRC_DIR/libnabo
mkdir -p build && cd build
cmake                                          \
  -DCMAKE_BUILD_TYPE=Release                   \
  -DCMAKE_CXX_FLAGS='-O3 -std=c++11'           \
  -DCMAKE_C_FLAGS='-O3'                        \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
  -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 \
  -DCMAKE_PREFIX_PATH=${PREFIX}                \
  -DBUILD_SHARED_LIBS=ON                       \
  -DCMAKE_VERBOSE_MAKEFILE=ON                  \
  ..
make -j${CPU_COUNT} install

# libpointmatcher
cd $SRC_DIR/libpointmatcher
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
  ..
make -j${CPU_COUNT} install

# fgr
cd $SRC_DIR/FastGlobalRegistration
FGR_SOURCE_DIR=$(pwd)/source
mkdir -p build && cd build
INC_FLAGS="-I${PREFIX}/include/eigen3 -I${PREFIX}/include -O3 -L${PREFIX}/lib -lflann_cpp -llz4 -O3 -std=c++11"
cmake                                        \
  -DCMAKE_BUILD_TYPE=Release                 \
  -DCMAKE_CXX_FLAGS="${INC_FLAGS}"           \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}      \
  -DCMAKE_PREFIX_PATH=${PREFIX}              \
  -DCMAKE_VERBOSE_MAKEFILE=ON                \
  -DFastGlobalRegistration_LINK_MODE=SHARED  \
  ${FGR_SOURCE_DIR}
make -j${CPU_COUNT}
# Install
FGR_INC_DIR=${PREFIX}/include/FastGlobalRegistration
mkdir -p ${FGR_INC_DIR}
/bin/cp -fv ${FGR_SOURCE_DIR}/FastGlobalRegistration/app.h ${FGR_INC_DIR}
FGR_LIB_DIR=${PREFIX}/lib
mkdir -p ${FGR_LIB_DIR}
/bin/cp -fv FastGlobalRegistration/libFastGlobalRegistrationLib* ${FGR_LIB_DIR}

# s2p
cd $SRC_DIR/s2p
baseDir=$(pwd)
export CFLAGS="-I$PREFIX/include -O3 -DNDEBUG -march=native"
export LDFLAGS="-L$PREFIX/lib"
# Extension
if [ "$(uname)" = "Darwin" ]; then
    EXT='.dylib'
else
    EXT='.so'
fi
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
cmake ..                                                  \
    -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CFLAGS" \
    -DPNG_LIBRARY_RELEASE="${PREFIX}/lib/libpng${EXT}"    \
    -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${EXT}"  \
    -DZLIB_LIBRARY_RELEASE="${PREFIX}/lib/libz${EXT}"     \
    -DJPEG_LIBRARY="${PREFIX}/lib/libjpeg${EXT}"
make -j${CPU_COUNT}
cd $baseDir
# msmw2
cd 3rdparty/msmw2
mkdir -p build
cd build
cmake ..                                                   \
    -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CFLAGS"  \
    -DPNG_LIBRARY_RELEASE="${PREFIX}/lib/libpng${EXT}"     \
    -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${EXT}"   \
    -DZLIB_LIBRARY_RELEASE="${PREFIX}/lib/libz${EXT}"      \
    -DJPEG_LIBRARY="${PREFIX}/lib/libjpeg${EXT}"
make -j${CPU_COUNT}
cd $baseDir
# Install the desired programs
BIN_DIR=${PREFIX}/plugins/stereo/mgm/bin
mkdir -p ${BIN_DIR}
/bin/cp -fv 3rdparty/mgm/mgm ${BIN_DIR}
BIN_DIR=${PREFIX}/plugins/stereo/msmw/bin
mkdir -p ${BIN_DIR}
/bin/cp -fv \
    3rdparty/msmw/build/libstereo/iip_stereo_correlation_multi_win2 \
    ${BIN_DIR}/msmw
BIN_DIR=${PREFIX}/plugins/stereo/msmw2/bin
mkdir -p ${BIN_DIR}
/bin/cp -fv \
    3rdparty/msmw2/build/libstereo_newversion/iip_stereo_correlation_multi_win2_newversion \
    ${BIN_DIR}/msmw2

# libelas
if [ "$(uname -m | grep -i arm)" != "" ]; then 
    echo Libelas does not build on Arm
else
    cd $SRC_DIR/libelas
    # Set the env
    export CFLAGS="-I$PREFIX/include -O3 -DNDEBUG -ffast-math -march=native"
    export LDFLAGS="-L$PREFIX/lib"
    if [ "$(uname)" = "Darwin" ]; then
        EXT='.dylib'
    else
        EXT='.so'
    fi
    # build
    mkdir -p build
    cd build
    cmake ..                                             \
    -DTIFF_LIBRARY_RELEASE="${PREFIX}/lib/libtiff${EXT}" \
    -DTIFF_INCLUDE_DIR="${PREFIX}/include"               \
    -DCMAKE_CXX_FLAGS="-I${PREFIX}/include"
    make -j${CPU_COUNT}
    # Copy the 'elas' tool to the plugins subdir meant for it
    BIN_DIR=${PREFIX}/plugins/stereo/elas/bin
    mkdir -p ${BIN_DIR}
    /bin/cp -fv elas ${BIN_DIR}/elas
fi

# Build stereo-pipeline
cd $SRC_DIR/StereoPipeline
mkdir -p build
cd build
cmake ..                             \
    -DCMAKE_PREFIX_PATH=${PREFIX}    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DUSE_ISIS=OFF                   \
    -DUSE_OPENEXR=OFF                \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT} install
