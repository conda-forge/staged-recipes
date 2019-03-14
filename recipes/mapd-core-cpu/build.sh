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
  # linux
  export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++"
  export CXXFLAGS="-std=c++14 -D_GLIBCXX_USE_CXX11_ABI=1"
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
  export ZLIB_ROOT=$PREFIX
  export CXXFLAGS="$CXXFLAGS -msse4.1"
  export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
  # export CC=
  # export CXX=
fi

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=debug \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DMAPD_IMMERSE_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_CUDA=off \
    -DENABLE_FOLLY=off \
    -DENABLE_JAVA_REMOTE_DEBUG=off \
    -DENABLE_PROFILE=off \
    -DENABLE_TESTS=on  \
    -DPREFER_STATIC_LIBS=off \
    $CMAKE_COMPILERS \
    ..

make -j4
make install

mkdir tmp 
$PREFIX/bin/initdb ./tmp
make sanity_tests

rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
