#!/usr/bin/env bash

set -ex

INPLACE_SED="sed -i"

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# libcuda.so is a machine specific library. For building, we use
# libcuda.so from stubs. For runtime, users must specify the location
# of libcuda.so.1 in the environment variable LD_LIBRARY_PATH.
export LDFLAGS="$LDFLAGS -L$PREFIX/lib/stubs -Wl,-rpath-link,$PREFIX/lib/stubs"
export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_LIBRARY_PATH=$PREFIX/lib/stubs"

# Enforce PREFIX instead of BUILD_PREFIX:
export ZLIB_ROOT=$PREFIX
export LibArchive_ROOT=$PREFIX
export Curses_ROOT=$PREFIX
export Glog_ROOT=$PREFIX
export Snappy_ROOT=$PREFIX
export Boost_ROOT=$PREFIX
export PNG_ROOT=$PREFIX
export GDAL_ROOT=$PREFIX

# Make sure -fPIC is not in CXXFLAGS (that some conda packages may
# add):
export CXXFLAGS="`echo $CXXFLAGS | sed 's/-fPIC//'`"

# Fixes error: no member named 'secure_getenv' in the global namespace
# Try disabling this for the next omniscidb release, see
#   https://github.com/omnisci/omniscidb/issues/374
export CXXFLAGS="$CXXFLAGS -Dsecure_getenv=getenv"

# Adjust OPENSSL_ROOT for conda environment. This ensures that
# openssl is picked up from host environment:
$INPLACE_SED 's!/usr/local/opt/openssl!\'$PREFIX'!g' CMakeLists.txt

# Avoid picking up boost/regexp header files from local system if
# there:
$INPLACE_SED 's!/usr/local!\'$PREFIX'!g' CMakeLists.txt

# Make sure that llvm-config and clang++ are from host environment,
# otherwise UdfTest will fail:
export PATH=$PREFIX/bin:$PATH

# Fixes nvcc linker failure (nvcc assumes libraries are in
# $PREFIX/lib64). Reconsider when new cudatoolk-dev is released:
export LIBRARIES="$LIBRARIES -L$PREFIX/lib"

# All these must be picked up from $PREFIX/bin
export CC=clang
export CXX=clang++
export CMAKE_CC=clang
export CMAKE_CXX=clang++
    
# Resolves `It appears that you have Arrow < 0.10.0`:
export CFLAGS="$CFLAGS -pthread"
export LDFLAGS="$LDFLAGS -lpthread -lrt -lresolv"

# fixes `undefined reference to
# `boost::system::detail::system_category_instance'`:
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_C_COMPILER=$CMAKE_CC -DCMAKE_CXX_COMPILER=$CMAKE_CXX"

mkdir -p build
cd build

cmake -Wno-dev \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=release \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_CUDA=on \
    -DENABLE_FOLLY=off \
    -DENABLE_JAVA_REMOTE_DEBUG=off \
    -DENABLE_PROFILER=off \
    -DENABLE_TESTS=on  \
    -DPREFER_STATIC_LIBS=off \
    $EXTRA_CMAKE_OPTIONS \
    ..

make -j $CPU_COUNT
make install

# skip tests when libcuda.so is not available
if [ "`ldd bin/initdb | grep "not found" | tr -d '[:space:]'`" == "libcuda.so.1=>notfound" ]; then
    echo "SKIP RUNNING SANITY TESTS: libcuda.so.1 not found"
else
    # Add g++ include paths for astparser. This used by the loadtime
    # UDF support, resolves not found include files errors: cstdint,
    # bits/c++config.h, features.h
    GCCVERSION=$(basename $(dirname $(g++ -print-libgcc-file-name)))
    export CPLUS_INCLUDE_PATH=$PREFIX/$HOST/include/c++/$GCCVERSION:$PREFIX/$HOST/include/c++/$GCCVERSION/$HOST:$PREFIX/$HOST/sysroot/usr/include

    mkdir tmp
    $PREFIX/bin/initdb tmp
    make sanity_tests
    rm -rf tmp
fi

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/omnisci_initdb
