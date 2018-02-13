#!/bin/bash

# install using pip from the whl files on PyPI

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp27/c/catboost/catboost-${PKG_VERSION}-cp27-none-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    elif [ "$PY_VER" == "3.4" ]; then
        WHL_FILE=https://pypi.org/packages/cp34/c/catboost/catboost-${PKG_VERSION}-cp34-none-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    elif [ "$PY_VER" == "3.5" ]; then
        #WHL_FILE=https://pypi.org/packages/cp35/c/catboost/catboost-${PKG_VERSION}-cp35-none-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
        WHL_FILE=http://storage.mds.yandex.net/get-devtools-opensource/250854/catboost-0.6.2-cp35-none-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://pypi.org/packages/cp36/c/catboost/catboost-${PKG_VERSION}-cp36-none-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://pypi.org/packages/cp27/c/catboost/catboost-${PKG_VERSION}-cp27-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.4" ]; then
        WHL_FILE=https://pypi.org/packages/cp34/c/catboost/catboost-${PKG_VERSION}-cp34-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.5" ]; then
        WHL_FILE=https://pypi.org/packages/cp35/c/catboost/catboost-${PKG_VERSION}-cp35-none-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://pypi.org/packages/cp36/c/catboost/catboost-${PKG_VERSION}-cp36-none-manylinux1_x86_64.whl
    fi
fi

pip install --no-deps $WHL_FILE
