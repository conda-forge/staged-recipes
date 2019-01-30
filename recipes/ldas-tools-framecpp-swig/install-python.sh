#!/bin/bash

set -ex
mkdir -p ${SRC_DIR}/build
pushd ${SRC_DIR}/build

# get python options (enable X, disable Y)
if [ "${PY3K}" -eq 1 ]; then
  PYTHONX="PYTHON3"
  PYTHONY="PYTHON2"
else
  PYTHONX="PYTHON2"
  PYTHONY="PYTHON3"
fi

# configure
cmake ${SRC_DIR} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DDISABLE_INSTALLATION_OF_SWIG_HEADERS=yes \
  -DENABLE_SWIG_${PYTHONY}=no \
  -DENABLE_SWIG_${PYTHONX}=yes \
  -D${PYTHONX}_EXECUTABLE=${PYTHON} \
  -D${PYTHONX}_VERSION=${PY_VER}

# build
cmake --build python -- -j ${CPU_COUNT}

# install
cmake --build python --target install

# test
ctest -VV
