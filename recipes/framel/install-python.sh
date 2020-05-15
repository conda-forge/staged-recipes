#!/bin/bash

set -ex

_builddir="_build${PY_VER}"
mkdir -pv ${_builddir}
pushd ${_builddir}

cmake ${SRC_DIR} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
	-DENABLE_C:BOOL=no \
	-DENABLE_MATLAB:BOOL=no \
	-DENABLE_PYTHON:BOOL=yes \
	-DPython3_EXECUTABLE:FILEPATH="${PYTHON}" \
;

# build
cmake --build ./Python --parallel ${CPU_COUNT} --verbose

# install
cmake --build ./Python --parallel ${CPU_COUNT} --verbose --target install
