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
#  DOES NOT WORK: https://pypi.io/packages/source/t/tensorflow-text/tensorflow_text-2.7.3-cp39-cp39-manylinux2010_x86_64.whl 
#  WORKS: https://pypi.debian.net/tensorflow-text/tensorflow_text-2.7.3-cp39-cp39-manylinux2010_x86_64.whl
#  See here: https://stackoverflow.com/a/53176862/8474894
#-------------------------------------------------------------------------------------------------------------
# PACKAGE_NAME="tensorflow-text"
# PKG_VERSION="2.7.3"


# WHEEL_URL_PREFIX="https://pypi.io/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}"

WHEEL_URL_PREFIX="https://pypi.debian.net/${PKG_NAME}/"

if [ "uname" == Darwin ]; then
    # if [ "$PKG_VERSION" == "2.6.0" ]; then
    #     WHEEL_URL_SUFFIX="macosx_10_9_x86_64"
    # elif [ "$PKG_VERSION" == "2.7.3" ]; then
    #     WHEEL_URL_SUFFIX="macosx_10_9_x86_64"
    # fi
    
    if [ "$PY_VER" == "3.7" ]; then
        WHEEL_URL_MID="m"
    elif [ "$PY_VER" == "3.8" ]; then
        WHEEL_URL_MID=""
    elif [ "$PY_VER" == "3.9" ]; then
        WHEEL_URL_MID=""
    fi 
fi

if [ "uname" == Linux ]; then
    # if [ "$PKG_VERSION" == "2.6.0" ]; then
    #     WHEEL_URL_SUFFIX="manylinux1_x86_64"
    # elif [ "$PKG_VERSION" == "2.7.3" ]; then
    #     WHEEL_URL_SUFFIX="manylinux2010_x86_64"
    # fi

    if [ "$PY_VER" == "3.7" ]; then
        # WHEEL_URL_MID="m"
        WHEEL_URL="https://files.pythonhosted.org/packages/70/0c/5d573a87248778e9422c53cd6a8c758f95da3598c7b246adf1545bb2ffca/tensorflow_text-2.6.0-cp37-cp37m-manylinux1_x86_64.whl"
    elif [ "$PY_VER" == "3.8" ]; then
        # WHEEL_URL_MID=""
        WHEEL_URL="https://files.pythonhosted.org/packages/6b/7c/c538ee905f04dd72753adf6f742666fedb06629475846fddee1cf8cc2cc3/tensorflow_text-2.6.0-cp38-cp38-manylinux1_x86_64.whl"
    elif [ "$PY_VER" == "3.9" ]; then
        # WHEEL_URL_MID=""
        WHEEL_URL="https://files.pythonhosted.org/packages/aa/29/f80bb874188c8b04a51805320e51501031b7e80a5b684fe3632313b7ba75/tensorflow_text-2.6.0-cp39-cp39-manylinux1_x86_64.whl"
    fi 
fi

# WHEEL_FILE="${PKG_NAME}-${PKG_VERSION}-cp${CONDA_PY}-cp${CONDA_PY}${WHEEL_URL_MID}-${WHEEL_URL_SUFFIX}.whl"

# WHEEL_URL="${WHEEL_URL_PREFIX}${WHEEL_FILE}"

pip install --no-deps "${WHEEL_URL}"
