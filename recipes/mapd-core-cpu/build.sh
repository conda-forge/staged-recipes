#!/usr/bin/env bash

set -ex

mkdir -p build
cd build

if [ $(uname) == Darwin ]; then
  # export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
  export CXXFLAGS="-std=c++14 -D_GLIBCXX_USE_CXX11_ABI=1"
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
  export ZLIB_ROOT=$PREFIX
  export LibArchive_ROOT=$PREFIX
else
  # linxu
  export CMAKE_COMPILERS=""
  export CXXFLAGS="-std=c++14 -D_GLIBCXX_USE_CXX11_ABI=1"
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
  export ZLIB_ROOT=$PREFIX
  export CXXFLAGS="$CXXFLAGS -msse4.1"
fi

cmake \
    -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DMAPD_IMMERSE_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_CUDA=off \
    -DENABLE_FOLLY=off \
    -DENABLE_PROFILE=off \
    -DENABLE_TESTS=on  \
    -DPREFER_STATIC_LIBS=off \
    ..

make -j4
make install

mkdir tmp 
$PREFIX/bin/initdb tmp
make sanity_tests

rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
