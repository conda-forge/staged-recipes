#!/bin/bash

set -e

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=${PREFIX}/lib:${LIBRARY_PATH}
export C_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)
export CPLUS_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)

if [ `uname` == Darwin ]; then
	BUILD_SPEC=macx-clang
else
	BUILD_SPEC=linux-g++
	# g++ cannot be found afterwards, solution taken from pyqt-feedstock
	mkdir bin || true
	pushd bin
		ln -s ${GXX} g++ || true
		ln -s ${GCC} gcc || true
	popd
	export PATH=${PWD}/bin:${PATH}
fi

cd ccore/
make ccore_x64

cd ../

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
