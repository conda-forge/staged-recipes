#!/usr/bin/env bash

set -ex

env

ls -la $BUILD_PREFIX/bin

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

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# Enforce PREFIX instead of BUILD_PREFIX:
export ZLIB_ROOT=$PREFIX
export LibArchive_ROOT=$PREFIX
export Curses_ROOT=$PREFIX

if [ $(uname) == Darwin ]; then
    # Darwin has only clang
    COMPILERNAME=clang   # options: clang
    export CC=$CLANG
    export CXX=$CLANGXX
else
    # Linux
    echo "uname=${uname}"
    COMPILERNAME=clang   # options: clang, gcc
    GXX=$BUILD_PREFIX/bin/$HOST-g++  # replace with $GXX
    GCCSYSROOT=$BUILD_PREFIX/$HOST/sysroot
    GCCVERSION=$(basename $(dirname $($GXX -print-libgcc-file-name)))
    GXXINCLUDEDIR=$BUILD_PREFIX/$HOST/include/c++/$GCCVERSION
    GCCLIBDIR=$BUILD_PREFIX/lib/gcc/$HOST/$GCCVERSION

    echo "GCCVERSION=$GCCVERSION"
    echo "GCCSYSROOT=$GCCSYSROOT"
    echo "GCCLIBDIR=$GCCLIBDIR"
    echo "GXXINCLUDEDIR=$GXXINCLUDEDIR"
    
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

    if [ "$COMPILERNAME" == "clang" ]; then
        export CC=$BUILD_PREFIX/bin/clang
        export CXX=$BUILD_PREFIX/bin/clang++
        export CXXFLAGS="$CXXFLAGS -I$CXXINC1 -I$CXXINC2 -I$CXXINC3"  # see CXXINC? above
        export CFLAGS="$CFLAGS -I$CXXINC3"                            # for pthread.h
    else
        # untested
        # Note that go overwrites CC and CXX with nonsense, hence we redefine these here:
        export CC=$BUILD_PREFIX/bin/$HOST-gcc
        export CXX=$BUILD_PREFIX/bin/$HOST-g++
    fi

    export LDFLAGS="$LDFLAGS -Wl,-L$GCCLIBDIR"             # resolves `cannot find -lgcc`
    # fixes `undefined reference to `boost::system::detail::system_category_instance'` issue:
    export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

    # When using clang/clang++, make sure that linker finds gcc .o/.a files:
    export CXXFLAGS="$CXXFLAGS  -B $GCCSYSROOT/usr/lib"  # resolves `cannot find crt1.o`
    export CXXFLAGS="$CXXFLAGS  -B $GCCLIBDIR"           # resolves `cannot find crtbegin.o`
    export CFLAGS="$CFLAGS  -B $GCCSYSROOT/usr/lib"      # resolves `cannot find crt1.o`
    export CFLAGS="$CFLAGS  -B $GCCLIBDIR"               # resolves `cannot find crtbegin.o`

    if [ -n "`cat /etc/*-release | grep CentOS`" ]; then
        echo
        #export CXXFLAGS="$CXXFLAGS -msse4.1"     # ?todo, might resolve a gcc specific issue
    fi
fi

# make sure that $LD is always used for a linker:
cp -v $LD $BUILD_PREFIX/bin/ld

export CMAKE_COMPILERS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"  

mkdir -p build
cd build

# TODO: change from debug to release
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=release \
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

make -j $CPU_COUNT
make install

mkdir tmp
$PREFIX/bin/initdb tmp
make sanity_tests
rm -rf tmp

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
