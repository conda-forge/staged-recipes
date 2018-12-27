#/usr/bin/env bash

set -ex 

function PushCMakeOption {
        if [ -n "$2" ] ; then
                cmake_opts+=" -D$1=$2"
        fi
}

#PYTHON_VERSION=${PYTHON_VERSION:-3.6.6}
CMAKE_BUILD_TYPE=RelWithDebInfo 
BUILD_DIR=${BUILD_DIR:-$(pwd)/build/manylinux} 

SOURCE_DIR=$(pwd)
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake_opts=""
#PushCMakeOption PYTHON_VERSION         ${PYTHON_VERSION}
PushCMakeOption CMAKE_BUILD_TYPE       ${CMAKE_BUILD_TYPE}
PushCMakeOption VISUS_INTERNAL_DEFAULT 1
PushCMakeOption DISABLE_OPENMP         1
PushCMakeOption VISUS_GUI              0
PushCMakeOption OPENSSL_ROOT_DIR       ${OPENSSL_ROOT_DIR}
#PushCMakeOption PYTHON_EXECUTABLE      ${PYTHON_EXECUTABLE}
#PushCMakeOption PYTHON_INCLUDE_DIR     ${PYTHON_INCLUDE_DIR}
#PushCMakeOption PYTHON_LIBRARY         ${PYTHON_LIBRARY}
#PushCMakeOption PYTHON_PLAT_NAME       manylinux1_x86_64
PushCMakeOption PYPI_USERNAME          ${PYPI_USERNAME}
PushCMakeOption PYPI_PASSWORD          ${PYPI_PASSWORD}

echo '#undef HAVE_STROPTS_H' | cat - ${SOURCE_DIR}/InternalLibs/curl/lib/if2ip.c > temp.c && mv temp.c ${SOURCE_DIR}/InternalLibs/curl/lib/if2ip.c

cmake ${cmake_opts} ${SOURCE_DIR} 
cmake --build . --target all -- -j 4
cmake --build . --target test

cmake --build . --target install 
