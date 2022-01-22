#!/bin/bash
# install using pip from the whl file provided by Google
#
## Reference:
#  - https://docs.conda.io/projects/conda-build/en/latest/user-guide/wheel-files.html
#    - https://github.com/conda-archive/conda-recipes/blob/a796713805ac8eceed191c0cb475b51f4d00718c/python/tensorflow/meta.yaml
#    - https://github.com/conda-archive/conda-recipes/blob/a796713805ac8eceed191c0cb475b51f4d00718c/python/tensorflow/build.sh
#  - https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html
#  - PR Example: https://github.com/conda-forge/tensorflow-feedstock/pull/22/files
#
## Example wheel filenames for tensorflow-text, version 2.7.3
#
#  tensorflow_text-2.7.3-cp39-cp39-win_amd64.whl
#  tensorflow_text-2.7.3-cp38-cp38-win_amd64.whl
#  tensorflow_text-2.7.3-cp37-cp37m-win_amd64.whl
#
#  tensorflow_text-2.7.3-cp39-cp39-manylinux2010_x86_64.whl
#  tensorflow_text-2.7.3-cp38-cp38-manylinux2010_x86_64.whl
#  tensorflow_text-2.7.3-cp37-cp37m-manylinux2010_x86_64.whl
#
#  tensorflow_text-2.7.3-cp39-cp39-macosx_10_9_x86_64.whl
#  tensorflow_text-2.7.3-cp38-cp38-macosx_10_9_x86_64.whl
#  tensorflow_text-2.7.3-cp37-cp37m-macosx_10_9_x86_64.whl
#
## Example Wheel URL:
#  https://pypi.io/packages/source/t/tensorflow-text/tensorflow_text-2.7.3-cp39-cp39-manylinux2010_x86_64.whl
#
#-------------------------------------------------------------------------------------------------------------
# PACKAGE_NAME="tensorflow-text"
# PKG_VERSION="2.7.3"


WHEEL_URL_PREFIX="https://pypi.io/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}"

if [ `uname` == Darwin ]; then
    if [ "$PKG_VER" == "2.6.0" ]; then
        WHEEL_URL_SUFFIX="macosx_10_9_x86_64"
    elif [ "$PKG_VER" == "2.7.3" ]; then
        WHEEL_URL_SUFFIX="macosx_10_9_x86_64"
    fi
    
    if [ "$PY_VER" == "3.7" ]; then
        WHEEL_URL_MID="m"
    elif [ "$PY_VER" == "3.8" ]; then
        WHEEL_URL_MID=""
    elif [ "$PY_VER" == "3.9" ]; then
        WHEEL_URL_MID=""
    fi 
fi

if [ `uname` == Linux ]; then
    if [ "$PKG_VER" == "2.6.0" ]; then
        WHEEL_URL_SUFFIX="manylinux1_x86_64"
    elif [ "$PKG_VER" == "2.7.3" ]; then
        WHEEL_URL_SUFFIX="manylinux2010_x86_64"
    fi
    if [ "$PY_VER" == "3.7" ]; then
        WHEEL_URL_MID="m"
    elif [ "$PY_VER" == "3.8" ]; then
        WHEEL_URL_MID=""
    elif [ "$PY_VER" == "3.9" ]; then
        WHEEL_URL_MID=""
    fi 
fi

WHEEL_URL="${WHEEL_URL_PREFIX}-cp${CONDA_PY}-cp${CONDA_PY}${WHEEL_URL_MID}-${WHEEL_URL_SUFFIX}.whl"

pip install --no-deps "${WHEEL_URL}${WHEEM_MID_CHAR}-${WHEEL_SUFFIX}.whl"
