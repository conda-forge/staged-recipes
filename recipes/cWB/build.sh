#!/bin/bash

set -ex

mkdir -pv build
pushd build

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_LIBDIR:PATH="lib" \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  ${SRC_DIR}

# build
cmake --build . --parallel ${CPU_COUNT} --verbose > build.log

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# install activate/deactivate scripts
for action in activate deactivate; do
	mkdir -p ${PREFIX}/etc/conda/${action}.d
        _target="${PREFIX}/etc/conda/${action}.d/activate-${PKG_NAME}.sh"
	echo "-- Installing: ${_target}"
	cp "${PREFIX}/etc/cwb/cwb-${action}.sh" "${_target}"
done
