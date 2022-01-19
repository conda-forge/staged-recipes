#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=true \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
ctest --parallel ${CPU_COUNT} --verbose

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

#install activate/deactivate scripts
for action in activate deactivate; do
	mkdir -p ${PREFIX}/etc/conda/${action}.d
	for ext in sh csh; do
		_target="${PREFIX}/etc/conda/${action}.d/activate-${PKG_NAME}.${ext}"
		echo "-- Installing: ${_target}"
		cp "${RECIPE_DIR}/${action}.${ext}" "${_target}"
	done
done
