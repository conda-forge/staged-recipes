#!/bin/bash
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --config Release --target all
cmake --build . --config Release --target install

export CFLAGS=${CFLAGS}" -I${PREFIX}/include -L${PREFIX}/lib"
$PYTHON setup.py install --single-version-externally-managed --record record.txt
