#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
  export MACOSX_VERSION_MIN=10.7
  export CC=clang
  export CXX=clang++
  export CFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
fi

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --config Release --target all
cmake --build . --config Release --target install

export CFLAGS=${CFLAGS}" -I${PREFIX}/include -L${PREFIX}/lib"
$PYTHON setup.py install --single-version-externally-managed --record record.txt
