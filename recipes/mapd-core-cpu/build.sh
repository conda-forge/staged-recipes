#!/usr/bin/env bash

set -ex

# mapd-core v 4.5.0 (or older) hardcodes /usr/bin/java Grab
# Calcite.cpp with a fix
# (https://github.com/omnisci/mapd-core/pull/316) from a repo:

# sed -i 's/\/usr\/bin\/java/'`which java|sed 's/\//\\\\\//g'`'/g' Calcite/Calcite.cpp
wget https://raw.githubusercontent.com/omnisci/mapd-core/7c1faa09dd88d0cc735b629048f74d71baa9179f/Calcite/Calcite.cpp
mv Calcite.cpp Calcite/

# conda build cannot find boost libraries from
# ThirdParty/lib. Actully, moving environment boost libraries to
# ThirdParty/lib does not make much sense. The following is just a
# quick workaround of the problem:
sed -i 's/DESTINATION ThirdParty\/lib/DESTINATION lib/g' CMakeLists.txt

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
  export CMAKE_COMPILERS=""
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
  export ZLIB_ROOT=$PREFIX
  #export CXXFLAGS="$CXXFLAGS -msse4.1"  # only Centos 7 requires this
  export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"  # fixes build failure
  export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"
  #export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
fi

# TODO: change from debug to release
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=debug \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DMAPD_IMMERSE_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_CUDA=off \
    -DENABLE_FOLLY=off \
    -DENABLE_JAVA_REMOTE_DEBUG=off \
    -DENABLE_PROFILER=off \
    -DENABLE_TESTS=on  \
    -DPREFER_STATIC_LIBS=off \
    $CMAKE_COMPILERS \
    ..

make -j `nproc`
make install

mkdir tmp
$PREFIX/bin/initdb tmp
make sanity_tests
rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
