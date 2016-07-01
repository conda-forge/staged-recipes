#!/bin/bash

if [ `uname` == Darwin ]; then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
    MAKE_JOBS=$(sysctl -n hw.ncpu)
fi

if [ `uname` == Linux ]; then
    MAKE_JOBS=$CPU_COUNT
fi

mkdir $PREFIX/qt/bin
cp $PREFIX/bin/moc $PREFIX/qt/bin/

$PYTHON configure.py \
        --verbose \
        --confirm-license \
        --assume-shared \
        -q $PREFIX/bin/qmake

make -j $MAKE_JOBS
make install

rm -rf $PREFIX/qt/bin
