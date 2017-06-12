#!/bin/bash

export CC="gcc"
export CXX="g++"

pushd code/liblbfgs
./autogen.sh
./configure --enable-sse2
make CFLAGS="-fPIC ${CFLAGS}"
popd

${PYTHON} setup.py build
${PYTHON} setup.py install
