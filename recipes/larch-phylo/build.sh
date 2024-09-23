#!/bin/bash

rm -rf build
mkdir build
cd build

CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-"Release"}
CMAKE_USE_USHER=${USE_USHER:-"ON"}
CMAKE_NUM_THREADS=${CMAKE_NUM_THREADS:-"4"}
MAKE_NUM_THREADS=${MAKE_NUM_THREADS:-"20"}
INCLUDE_LARCH_TEST=${INCLUDE_LARCH_TEST:-"false"}

echo "INCLUDE_LARCH_TEST: ${INCLUDE_LARCH_TEST}"
echo "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}"
echo "CMAKE_USE_USHER: ${CMAKE_USE_USHER}"
echo "CMAKE_NUM_THREADS: ${CMAKE_NUM_THREADS}"
echo "MAKE_NUM_THREADS: ${MAKE_NUM_THREADS}"

export CMAKE_NUM_THREADS=${CMAKE_NUM_THREADS}
cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DUSE_USHER=${CMAKE_USE_USHER} ..
make -j${MAKE_NUM_THREADS}

mkdir -p $PREFIX/lib
cp $(find . -name *.so*) $PREFIX/lib/

mkdir -p $PREFIX/bin
cp larch-usher $PREFIX/bin/larch-usher
cp larch-dagutil $PREFIX/bin/larch-dagutil
cp larch-dag2dot $PREFIX/bin/larch-dag2dot

if [[ ${INCLUDE_LARCH_TEST} == true ]]; then
    cp larch-test $PREFIX/bin/larch-test
fi

