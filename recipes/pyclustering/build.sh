#!/bin/bash

set -e

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
make ccore_x86

cd ../

PYTHONPATH=`pwd`
export PYTHONPATH=${PYTHONPATH}

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
