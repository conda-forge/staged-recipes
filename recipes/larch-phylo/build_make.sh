#!/bin/bash

mkdir -p build
cd build

MAKE_NUM_THREADS=${MAKE_NUM_THREADS:-"20"}
LARCH_INCLUDE_TEST=${LARCH_INCLUDE_TEST:-"false"}
LARCH_RUN_TEST=${LARCH_RUN_TEST:-"false"}

echo "MAKE_NUM_THREADS: ${MAKE_NUM_THREADS}"
echo "LARCH_INCLUDE_TEST: ${LARCH_INCLUDE_TEST}"
echo "LARCH_RUN_TEST: ${LARCH_RUN_TEST}"

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
