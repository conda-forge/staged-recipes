#!/bin/bash

rm -rf build
mkdir build
cd build

CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-"Release"}
CMAKE_USE_USHER=${USE_USHER:-"ON"}
CMAKE_NUM_THREADS=${CMAKE_NUM_THREADS:-"8"}
MAKE_NUM_THREADS=${MAKE_NUM_THREADS:-"20"}
LARCH_INCLUDE_TEST=${LARCH_INCLUDE_TEST:-"false"}
LARCH_RUN_TEST=${LARCH_RUN_TEST:-"true"}

echo "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}"
echo "CMAKE_USE_USHER: ${CMAKE_USE_USHER}"
echo "CMAKE_NUM_THREADS: ${CMAKE_NUM_THREADS}"
echo "MAKE_NUM_THREADS: ${MAKE_NUM_THREADS}"
echo "LARCH_INCLUDE_TEST: ${LARCH_INCLUDE_TEST}"
echo "LARCH_RUN_TEST: ${LARCH_RUN_TEST}"

export CMAKE_NUM_THREADS=${CMAKE_NUM_THREADS}
cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DUSE_USHER=${CMAKE_USE_USHER} ..
make -j${MAKE_NUM_THREADS}

mkdir -p $PREFIX/lib
cp $(find . -name *.so*) $PREFIX/lib/

if [[ ${LARCH_RUN_TEST} == true ]]; then
    ln -s ../data
    ./larch-test -tag slow
fi

mkdir -p $PREFIX/bin
cp larch-usher $PREFIX/bin/larch-usher
cp larch-dagutil $PREFIX/bin/larch-dagutil
cp larch-dag2dot $PREFIX/bin/larch-dag2dot

if [[ ${LARCH_INCLUDE_TEST} == true ]]; then
    cp larch-test $PREFIX/bin/larch-test
fi
