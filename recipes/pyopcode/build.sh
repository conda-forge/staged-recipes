#!/bin/bash

source activate "${CONDA_DEFAULT_ENV}"

cd pyopcode
mkdir build
cd build

cmake ../src \
        -Wno-dev \
        -DCMAKE_BUILD_TYPE=${BUILD_CONFIG} \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DPYTHON_INCLUDE_DIR:PATH=$include_path \
        -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY \
        -DNUMPY_INCLUDE_DIR:PATH="${SP_DIR}/numpy/core/include" \
        -DBOOST_ROOT:PATH=${PREFIX}/include

make -j${CPU_COUNT}

cd ..

cp ./build/lib_pyopcode.so "${PREFIX}/lib/python${PY_VER}/_pyopcode.so"

cd ..

python setup.py bdist
python setup.py install
