#!/bin/bash

set -ex

mkdir -pv build
pushd build

cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  ${SRC_DIR}

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install
cmake --install .

# install activate/deactivate scripts
for action in activate deactivate; do
	mkdir -p ${PREFIX}/etc/conda/${action}.d
        _target="${PREFIX}/etc/conda/${action}.d/${action}-${PKG_NAME}.sh"
	echo "-- Installing: ${_target}"
	cp "${PREFIX}/etc/cwb/cwb-${action}.sh" "${_target}"
done
