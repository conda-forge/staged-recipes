#! /bin/bash

cmake_args=(
    -DBUILD_DOC=OFF
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_MODULE_PATH=../cmake-modules
    -DGTEST_INCLUDE_DIRS=$PREFIX/include
)

if [ $(uname) = Darwin ] ; then
    cmake_args+=(
	-DCMAKE_CXX_FLAGS="$CXXFLAGS -stdlib=libc++"
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
    )
fi

mkdir condabuild
cd condabuild
cmake "${cmake_args[@]}" ..
make VERBOSE=1 # note: not parallel-compatible
make install
