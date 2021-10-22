#!/bin/bash

# Based on
# - https://bitbucket.org/multicoreware/x265_git/src/master/build/linux/multilib.sh
# - https://github.com/Homebrew/homebrew-core/blob/master/Formula/x265.rb

set -ex

mkdir 8bit 10bit 12bit

# --- Pixel depth 12
cd 12bit
cmake ../source                      \
    -DHIGH_BIT_DEPTH=ON              \
    -DEXPORT_C_API=OFF               \
    -DENABLE_SHARED=OFF              \
    -DENABLE_CLI=OFF                 \
    -DMAIN12=ON                      \
    -DCMAKE_BUILD_TYPE="Release"     \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \

make -j${CPU_COUNT}

# --- Pixel depth 10
cd ../10bit
cmake ../source                      \
    -DHIGH_BIT_DEPTH=ON              \
    -DEXPORT_C_API=OFF               \
    -DENABLE_SHARED=OFF              \
    -DENABLE_CLI=OFF                 \
    -DENABLE_HDR10_PLUS=ON           \
    -DCMAKE_BUILD_TYPE="Release"     \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \

make -j${CPU_COUNT}

# --- Pixel depth 8, and put it all together
cd ../8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a

cmake ../source                                  \
    -DCMAKE_BUILD_TYPE="Release"                 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
    -DENABLE_SHARED=TRUE                         \
    -DLINKED_10BIT=ON                            \
    -DLINKED_12BIT=ON                            \
    -DEXTRA_LIB='x265_main10.a;x265_main12.a'    \
    -DEXTRA_LINK_FLAGS='-L .'                    \

make -j${CPU_COUNT}

if [[ $(uname) == "Darwin" ]]; then
    libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a
else
    ar cr libx265.a libx265_main.a libx265_main10.a libx265_main12.a
    ranlib libx265.a
fi

make install
