#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ `uname` == "Darwin" ]; then
    touch header_snippet
    echo -e "#define _DARWIN_C_SOURCE\n" > header_snippet
    mv ${SRC_DIR}/tests/cpp_unit.cpp ${SRC_DIR}/tests/cpp_unit.cpp2
    cat header_snippet ${SRC_DIR}/tests/cpp_unit.cpp2 > ${SRC_DIR}/tests/cpp_unit.cpp
    rm ${SRC_DIR}/tests/cpp_unit.cpp2
fi

mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    ${SRC_DIR}

make install
make test