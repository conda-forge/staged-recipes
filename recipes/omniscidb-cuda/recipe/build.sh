#!/usr/bin/env bash

set -ex

# Make sure we are in the right place
cd $SRC_DIR

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

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
export BLOSC_ROOT=$PREFIX

# Make sure -fPIC is not in CXXFLAGS (that some conda packages may
# add):
export CXXFLAGS="`echo $CXXFLAGS | sed 's/-fPIC//'`"

# Fixes https://github.com/Quansight/pearu-sandbox/issues/7
#       https://github.com/omnisci/omniscidb/issues/374
export CXXFLAGS="$CXXFLAGS -Dsecure_getenv=getenv"

# Adjust OPENSSL_ROOT for conda environment. This ensures that
# openssl is picked up from host environment:
sed -i 's!/usr/local/opt/openssl!\'$PREFIX'!g' CMakeLists.txt

# Avoid picking up boost/regexp header files from local system if
# there:
sed -i 's!/usr/local!\'$PREFIX'!g' CMakeLists.txt

# Make sure that llvm-config and clang++ are from host environment,
# otherwise UdfTest will fail:
export PATH=$PREFIX/bin:$PATH

# Fixes nvcc linker failure (nvcc assumes libraries are in
# $PREFIX/lib64). Reconsider when new cudatoolk-dev is released:
export LIBRARIES="$LIBRARIES -L$PREFIX/lib"

# All these must be picked up from $PREFIX/bin
CMAKE_ENV="CC=clang CXX=clang++"

# Resolves `It appears that you have Arrow < 0.10.0`:
export CFLAGS="$CFLAGS -pthread"
export LDFLAGS="$LDFLAGS -pthread -lrt -lresolv"

# fixes `undefined reference to
# `boost::system::detail::system_category_instance'`:
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_LIBRARY_PATH=$CUDA_HOME/lib64/stubs"
export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME"

mkdir -p build
cd build

$CMAKE_ENV cmake -Wno-dev \
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

(which lscpu && which grep && which awk && which bc)
if [ $? -eq 0 ]; then
    export CORES_PER_SOCKET=`lscpu | grep 'Core(s) per socket' | awk '{print $NF}'`
    export NUMBER_OF_SOCKETS=`lscpu | grep 'Socket(s)' | awk '{print $NF}'`
    export NCORES=`echo "$CORES_PER_SOCKET * $NUMBER_OF_SOCKETS" | bc`
    make -j $NCORES
else
    make -j $CPU_COUNT
fi

make install

export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# DEBUG:
echo "CUDA_HOME=$CUDA_HOME"
echo "PATH=$PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "LDFLAGS=$LDFLAGS"
${CC} --print-sysroot
ls -la `${CC} --print-sysroot`/lib/libcuda*

# skip tests when libcuda.so is not available
if [ "`ldd bin/initdb | grep "not found" | tr -d '[:space:]'`" == "libcuda.so.1=>notfound" ]; then
    echo "SKIP RUNNING SANITY TESTS: libcuda.so.1 not found"
else
    # Add g++ include paths for astparser. This is used by the
    # loadtime UDF support, resolves not found include files errors:
    # cstdint, bits/c++config.h, features.h
    GCCVERSION=$(basename $(dirname $($GXX -print-libgcc-file-name)))
    export CPLUS_INCLUDE_PATH=$PREFIX/$HOST/include/c++/$GCCVERSION:$PREFIX/lib/gcc/$HOST/$GCCVERSION/include

    mkdir tmp
    $PREFIX/bin/initdb tmp
    make sanity_tests
    rm -rf tmp
fi

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/omnisci_initdb
