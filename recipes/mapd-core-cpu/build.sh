#!/usr/bin/env bash

set -ex

env

# sed -i option is handled differently in Linux and OSX
if [ $(uname) == Darwin ]; then
    export INPLACE_SED="sed -i \"\" -e"
else
    export INPLACE_SED="sed -i"
fi

# mapd-core v 4.5.0 (or older) hardcodes /usr/bin/java Grab
# Calcite.cpp with a fix
# (https://github.com/omnisci/mapd-core/pull/316) from a repo:
wget https://raw.githubusercontent.com/omnisci/mapd-core/7c1faa09dd88d0cc735b629048f74d71baa9179f/Calcite/Calcite.cpp
mv Calcite.cpp Calcite/

# conda build cannot find boost libraries from
# ThirdParty/lib. Actully, moving environment boost libraries to
# ThirdParty/lib does not make much sense. The following is just a
# quick workaround of the problem:
$INPLACE_SED 's/DESTINATION ThirdParty\/lib/DESTINATION lib/g' CMakeLists.txt

# Add include directories to clang++ for building RuntimeFunctions.bc and ExtensionFunctions.ast
# This fixes failures about not finding cassert, ... include files.
CXXINC1=$BUILD_PREFIX/$HOST/include/c++/7.3.0
CXXINC2=$BUILD_PREFIX/$HOST/include/c++/7.3.0/$HOST
CXXINC3=$BUILD_PREFIX/$HOST/sysroot/usr/include
mv QueryEngine/CMakeLists.txt QueryEngine/CMakeLists.txt-orig
echo -e "set(CXXINC1 \"-I$CXXINC1\")" > QueryEngine/CMakeLists.txt
echo -e "set(CXXINC2 \"-I$CXXINC2\")" >> QueryEngine/CMakeLists.txt
echo -e "set(CXXINC3 \"-I$CXXINC3\")" >> QueryEngine/CMakeLists.txt
cat QueryEngine/CMakeLists.txt-orig >> QueryEngine/CMakeLists.txt
$INPLACE_SED 's/ARGS -std=c++14/ARGS -std=c++14 \${CXXINC1} \${CXXINC2} \${CXXINC3}/g' QueryEngine/CMakeLists.txt

# When using clang/clang++, make sure that linker finds gcc .o/.a files (todo: can the flags reduced?):
export CXXFLAGS="$CXXFLAGS -B $BUILD_PREFIX/$HOST/sysroot/usr/lib -B $BUILD_PREFIX/$HOST/sysroot/lib -B $BUILD_PREFIX/lib/gcc/$HOST/7.3.0/ --gcc-toolchain=$BUILD_PREFIX/$HOST --sysroot=$BUILD_PREFIX/$HOST/sysroot"
export CFLAGS="$CFLAGS -B $BUILD_PREFIX/$HOST/sysroot/usr/lib -B $BUILD_PREFIX/$HOST/sysroot/lib -B $BUILD_PREFIX/lib/gcc/$HOST/7.3.0/ --gcc-toolchain=$BUILD_PREFIX/$HOST --sysroot=$BUILD_PREFIX/$HOST/sysroot"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -Wl,-L$BUILD_PREFIX/$HOST/sysroot/usr/lib -Wl,-L$BUILD_PREFIX/lib/gcc/$HOST/7.3.0/"
#export ZLIB_ROOT=$PREFIX   # todo: make sure that it is not needed on Darwin

# Prefer clang/clang++:
if [ True ]; then
  export CC=$BUILD_PREFIX/bin/clang
  export CXX=$BUILD_PREFIX/bin/clang++
  export CXXFLAGS="$CXXFLAGS -I$CXXINC1 -I$CXXINC2"
else
  export CC=$BUILD_PREFIX/bin/$HOST-gcc
  export CXX=$BUILD_PREFIX/bin/$HOST-g++
fi

# fixes `undefined reference to `boost::system::detail::system_category_instance'` issue:
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

if [ $(uname) == Darwin ]; then
  # export MACOSX_DEPLOYMENT_TARGET="10.9"
  export LibArchive_ROOT=$PREFIX
fi

# only Centos 7 seems to require -msse4.1
if [ -n "`cat /etc/*-release | grep CentOS`" ]; then
   export CXXFLAGS="$CXXFLAGS -msse4.1"
fi

export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

mkdir -p build
cd build

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
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    ..

make -j `nproc`
make install

mkdir tmp
$PREFIX/bin/initdb tmp
make sanity_tests
rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
