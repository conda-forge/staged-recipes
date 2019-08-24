#!/usr/bin/env bash

set -ex

# sed -i option is handled differently in Linux and OSX
if [ $(uname) == Darwin ]; then
    INPLACE_SED="sed -i \"\" -e"
else
    INPLACE_SED="sed -i"
fi

# conda build cannot find boost libraries from
# ThirdParty/lib. Actually, moving environment boost libraries to
# ThirdParty/lib does not make much sense. The following is just a
# quick workaround of the problem. Upstream will remove the relevant
# code from CMakeLists.txt as not needed.
$INPLACE_SED 's:DESTINATION ThirdParty/lib:DESTINATION lib:g' CMakeLists.txt

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# libcuda.so is a machine specific library. For building, we use
# libcuda.so from stubs. For runtime, users must specify the location
# of libcuda.so.1 in the environment variable LD_LIBRARY_PATH.
export LDFLAGS="$LDFLAGS -L$PREFIX/lib/stubs -Wl,-rpath-link,$PREFIX/lib/stubs"
export EXTRA_CMAKE_OPTIONS="-DCMAKE_LIBRARY_PATH=$PREFIX/lib/stubs"

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

# go overwrites CC and CXX with nonsense (see
# https://github.com/conda-forge/go-feedstock/issues/47), hence we
# redefine these below. Reset GO env variables for omniscidb build
# (IIRC, it is needed for CUDA support):
#export CGO_ENABLED=1
#export CGO_LDFLAGS=
#export CGO_CFLAGS=$CFLAGS
#export CGO_CPPFLAGS=

# Adjust OPENSSL_ROOT for conda environment. This ensures that
# openssl is picked up from host environment:
$INPLACE_SED 's!/usr/local/opt/openssl!\'$PREFIX'!g' CMakeLists.txt

# Avoid picking up boost/regexp header files from local system if
# there:
$INPLACE_SED 's!/usr/local!\'$PREFIX'!g' CMakeLists.txt

# Make sure that llvm-config and clang++ are from host environment,
# otherwise (i) the build environment may contain clang/llvm-4.0.1
# that will interfer badly with llvmdev/clangdev in the host
# environment, (ii) UdfTest will fail:
export PATH=$PREFIX/bin:$PATH

# Linux
echo "uname=${uname}"
# must use gcc compiler as llvmdev is built with gcc and there
# exists ABI incompatibility between llvmdev-7 built with gcc and
# clang. Using clang with llvmdev-8 is fine.
COMPILERNAME=clang                      # options: clang, gcc

# Fixes nvcc linker failure (nvcc assumes libraries are in $PREFIX/lib64):
export LIBRARIES="$LIBRARIES -L$PREFIX/lib"

if [ "$COMPILERNAME" == "clang" ]; then
    # All these must be picked up from $PREFIX/bin
    export CC=clang
    export CXX=clang++
    export CMAKE_CC=clang
    export CMAKE_CXX=clang++
    
    # Resolves `It appears that you have Arrow < 0.10.0`:
    export CFLAGS="$CFLAGS -pthread"
    export LDFLAGS="$LDFLAGS -lpthread -lrt -lresolv"
else
    export CC=clang
    export CXX=  # not used
    export CMAKE_CC=$HOST-gcc
    export CMAKE_CXX=$HOST-g++
fi

##GXX=$HOST-g++         # replace with $GXX
##GCCVERSION=$(basename $(dirname $($GXX -print-libgcc-file-name)))
##GXXINCLUDEDIR=$PREFIX/$HOST/include/c++/$GCCVERSION
# Add gcc include directory to astparser, resolves `not found
# include file`: cstdint
# On Ubuntu 18.04 tests pass without this patch, however, the
# patch is required on Centos and apparently on CI machines
# (Ubuntu 16.04)
##$INPLACE_SED 's!arg_vector\[3\] = {arg0, arg1!arg_vector\[4\] = {arg0, arg1, "-extra-arg=-I'$GXXINCLUDEDIR'"!g' QueryEngine/UDFCompiler.cpp

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
    mkdir tmp
    $PREFIX/bin/initdb tmp
    make sanity_tests
    rm -rf tmp
fi

# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/omnisci_initdb
