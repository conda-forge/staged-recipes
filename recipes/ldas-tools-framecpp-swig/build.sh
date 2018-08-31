#!/bin/bash

mkdir -p build
pushd build

if [ "${PY3K}" -eq 1 ]; then
	_PYTHON_BUILD_OPTS="-DENABLE_SWIG_PYTHON2=no -DENABLE_SWIG_PYTHON3=yes -DPYTHON3_EXECUTABLE=${PYTHON}"
else
	_PYTHON_BUILD_OPTS="-DENABLE_SWIG_PYTHON3=no -DENABLE_SWIG_PYTHON2=yes -DPYTHON2_EXECUTABLE=${PYTHON}"
fi

cmake .. \
	${_PYTHON_BUILD_OPTS} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build . --config Release -- -j${CPU_COUNT}
ctest -V
cmake --build . --target install

popd
