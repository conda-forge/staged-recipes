#!/usr/bin/env bash

set -ex

env

GCCSYSROOT=$BUILD_PREFIX/$HOST/sysroot
GCCVERSION=$(basename $(dirname $($GCC -print-libgcc-file-name)))
GXXINCLUDEDIR=$BUILD_PREFIX/$HOST/include/c++/$GCCVERSION
GCCLIBDIR=$BUILD_PREFIX/lib/gcc/$HOST/$GCCVERSION

echo "GCCVERSION=$GCCVERSION"
echo "GCCSYSROOT=$GCCSYSROOT"
echo "GCCLIBDIR=$GCCLIBDIR"
echo "GXXINCLUDEDIR=$GXXINCLUDEDIR"

# sed -i option is handled differently in Linux and OSX
if [ $(uname) == Darwin ]; then
    INPLACE_SED="sed -i \"\" -e"
else
    INPLACE_SED="sed -i"
fi

# mapd-core v 4.5.0 (or older) hardcodes /usr/bin/java. Grab
# Calcite.cpp with a fix
# (https://github.com/omnisci/mapd-core/pull/316) from a repo:
wget https://raw.githubusercontent.com/omnisci/mapd-core/7c1faa09dd88d0cc735b629048f74d71baa9179f/Calcite/Calcite.cpp
mv Calcite.cpp Calcite/

# conda build cannot find boost libraries from
# ThirdParty/lib. Actually, moving environment boost libraries to
# ThirdParty/lib does not make much sense. The following is just a
# quick workaround of the problem. Upstream will remove the relevant
# code from CMakeLists.txt as not needed.
$INPLACE_SED 's/DESTINATION ThirdParty\/lib/DESTINATION lib/g' CMakeLists.txt

# Fix not found include file errors:
CXXINC1=$GXXINCLUDEDIR            # cassert, ...
CXXINC2=$GXXINCLUDEDIR/$HOST      # <string> requires bits/c++config.h
CXXINC3=$GCCSYSROOT/usr/include   # pthread.h

# Add include directories for explicit clang++ call in
# QueryEngine/CMakeLists.txt for building RuntimeFunctions.bc and
# ExtensionFunctions.ast:
mv QueryEngine/CMakeLists.txt QueryEngine/CMakeLists.txt-orig
echo -e "set(CXXINC1 \"-I$CXXINC1\")" > QueryEngine/CMakeLists.txt
echo -e "set(CXXINC2 \"-I$CXXINC2\")" >> QueryEngine/CMakeLists.txt
echo -e "set(CXXINC3 \"-I$CXXINC3\")" >> QueryEngine/CMakeLists.txt
cat QueryEngine/CMakeLists.txt-orig >> QueryEngine/CMakeLists.txt
$INPLACE_SED 's/ARGS -std=c++14/ARGS -std=c++14 \${CXXINC1} \${CXXINC2} \${CXXINC3}/g' QueryEngine/CMakeLists.txt

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export LDFLAGS="$LDFLAGS -Wl,-L$GCCLIBDIR"             # resolves `cannot find -lgcc`
#export ZLIB_ROOT=$PREFIX   # ?todo: make sure that it is not needed on Darwin, BUILD_PREFIX?

# Prefer clang/clang++:
if [ True ]; then
  export CC=$BUILD_PREFIX/bin/clang
  export CXX=$BUILD_PREFIX/bin/clang++
  export CXXFLAGS="$CXXFLAGS -I$CXXINC1 -I$CXXINC2 -I$CXXINC3"  # see CXXINC? above
  export CFLAGS="$CFLAGS -I$CXXINC3"   # for pthread.h
else
  # untested
  export CC=$BUILD_PREFIX/bin/$HOST-gcc
  export CXX=$BUILD_PREFIX/bin/$HOST-g++
fi

# fixes `undefined reference to `boost::system::detail::system_category_instance'` issue:
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

# When using clang/clang++, make sure that linker finds gcc .o/.a files (todo: can the flags reduced?):
#export CXXFLAGS="$CXXFLAGS  -B $BUILD_PREFIX/bin"                   # ? no need in: centos
export CXXFLAGS="$CXXFLAGS  -B $GCCSYSROOT/usr/lib"  # resolves `cannot find crt1.o`
#export CXXFLAGS="$CXXFLAGS  -B $BUILD_PREFIX/$HOST/sysroot/lib"     # ? no need in: centos
export CXXFLAGS="$CXXFLAGS  -B $GCCLIBDIR"   # resolves `cannot find crtbegin.o`

#export CFLAGS="$CFLAGS  -B $BUILD_PREFIX/bin"                       # ? no need in: centos
export CFLAGS="$CFLAGS  -B $GCCSYSROOT/usr/lib"      # resolves `cannot find crt1.o`
#export CFLAGS="$CFLAGS  -B $BUILD_PREFIX/$HOST/sysroot/lib"         # ? no need in: centos
export CFLAGS="$CFLAGS  -B $GCCLIBDIR"       # resolves `cannot find crtbegin.o`

# make sure that $LD is always used for a linker:
cp -v $LD $BUILD_PREFIX/bin/ld

if [ $(uname) == Darwin ]; then
  echo
  # export MACOSX_DEPLOYMENT_TARGET="10.9"  # ?todo
  # export LibArchive_ROOT=$PREFIX            # ?todo, shouldn't that be BUILD_PREFIX?
fi


if [ -n "`cat /etc/*-release | grep CentOS`" ]; then
   echo
   #export CXXFLAGS="$CXXFLAGS -msse4.1"     # ?todo, might resolve a gcc specific issue
fi

export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"  
#export CMAKE_COMPILERS="$CMAKE_COMPILERS -DCMAKE_MAKE_PROGRAM=$BUILD_PREFIX/bin/make"  # ? no need in: centos

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
    ..

make -j `nproc`
make install

mkdir tmp
$PREFIX/bin/initdb tmp
#make sanity_tests
rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
