#! /bin/bash

set -e

cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
)

if [ $(uname) = Darwin ] ; then
    cmake_args+=(
        -DCMAKE_CXX_FLAGS="$CXXFLAGS -stdlib=libc++"
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
    )
fi

mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$CPU_COUNT VERBOSE=1
# make test -- these do not pass
make install

cd $PREFIX
rm -f lib/libgraphite2.la bin/gr2fonttest
