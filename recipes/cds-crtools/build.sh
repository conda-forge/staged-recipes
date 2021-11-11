#!/bin/bash

set -e

mkdir -p _build
cd _build

# hack a symlink for rpcgen
ln -s ${CPP} ${BUILD_PREFIX}/bin/cpp

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DENABLE_PYTHON2:BOOL=FALSE \
	-DENABLE_PYTHON3:BOOL=FALSE \
	-DGDS_INCLUDE_DIR="${PREFIX}/include/gds" \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ $build_platform == $target_platform || $target_platform == linux-* ]]; then
	ctest --parallel ${CPU_COUNT} --verbose
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
