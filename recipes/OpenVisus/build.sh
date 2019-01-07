#/usr/bin/env bash

set -ex 

#conda install -c conda-forge numpy

PYTHON_EXECUTABLE=$PYTHON
PYTHON_VERSION=${PYTHON_VERSION:-2.7}
#/opt/conda/bin/python
#PYTHON_LIBRARY=/opt/conda/bin/libpython3.6m.so
#PYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m/

function PushCMakeOption {
        if [ -n "$2" ] ; then
                cmake_opts+=" -D$1=$2"
        fi
}

CMAKE_BUILD_TYPE=RelWithDebInfo 
BUILD_DIR=${BUILD_DIR:-$(pwd)/build} 

SOURCE_DIR=$(pwd)
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake_opts=""
PushCMakeOption PYTHON_EXECUTABLE      ${PYTHON_EXECUTABLE}
PushCMakeOption PYTHON_VERSION         ${PYTHON_VERSION}
PushCMakeOption CMAKE_BUILD_TYPE       ${CMAKE_BUILD_TYPE}
PushCMakeOption VISUS_INTERNAL_DEFAULT 0
PushCMakeOption VISUS_INTERNAL_ZLIB    1
PushCMakeOption VISUS_INTERNAL_LZ4     1
PushCMakeOption VISUS_INTERNAL_TINYXML 1
PushCMakeOption VISUS_INTERNAL_FREEIMAGE 1
PushCMakeOption VISUS_INTERNAL_OPENSSL 1
PushCMakeOption DISABLE_OPENMP         1
PushCMakeOption VISUS_GUI              0
PushCMakeOption CMAKE_INSTALL_PREFIX   $PREFIX

#PushCMakeOption OPENSSL_ROOT_DIR       ${OPENSSL_ROOT_DIR}
#PushCMakeOption PYTHON_INCLUDE_DIR     ${PYTHON_INCLUDE_DIR}
#PushCMakeOption PYTHON_LIBRARY         ${PYTHON_LIBRARY}
#PushCMakeOption PYTHON_PLAT_NAME       manylinux1_x86_64
#PushCMakeOption PYPI_USERNAME          ${PYPI_USERNAME}
#PushCMakeOption PYPI_PASSWORD          ${PYPI_PASSWORD}
#PushCMakeOption NUMPY_INCLUDE_DIR      /opt/conda/lib/python3.6/site-packages/numpy/core/include

#${PYTHON_EXECUTABLE} -c "import numpy; print(numpy.__file__)"

cmake ${cmake_opts} ${SOURCE_DIR} 
cmake --build . --target all -- -j 4
#cmake --build . --target test
#cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ${SOURCE_DIR}
#cmake --build . --target install 

#some debug
echo $PREFIX
ls $PREFIX

cp -R * $PREFIX/

#export MYPATH=$SRC_DIR/build/manylinux/install/

# here I was trying to test where the module is supposed to be deployed
cd $PREFIX
ls
$PYTHON -c "import OpenVisus"
