#!/bin/bash

# Build libinchi
mkdir -p $SRC_DIR/INCHI_API/bin/Linux
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include/inchi
cd $SRC_DIR/INCHI_API/libinchi/gcc

make C_COMPILER="$CC" SHARED_LINK="$CC -shared" LINKER="$CC -s -Wl,-R,''"
cp $SRC_DIR/INCHI_API/libinchi/src/*.h $PREFIX/include/inchi/
cp $SRC_DIR/INCHI_BASE/src/*.h $PREFIX/include/inchi/

if [[ `uname` == 'Darwin' ]]; then
    cp $SRC_DIR/INCHI_API/bin/Linux/libinchi.1.05.00.dylib $PREFIX/lib/libinchi.1.05.00.dylib
    ln -s $PREFIX/lib/libinchi.1.05.00.dylib $PREFIX/lib/libinchi.1.dylib
    ln -s $PREFIX/lib/libinchi.1.05.00.dylib $PREFIX/lib/libinchi.dylib
else
    cp $SRC_DIR/INCHI_API/bin/Linux/libinchi.so.1.05.00 $PREFIX/lib/libinchi.so.1.05.00
    ln -s $PREFIX/lib/libinchi.so.1.05.00 $PREFIX/lib/libinchi.so.1
    ln -s $PREFIX/lib/libinchi.so.1.05.00 $PREFIX/lib/libinchi.so
fi

# Build inchi-1 executable
mkdir -p $SRC_DIR/INCHI_EXE/bin/Linux
mkdir -p $PREFIX/bin
cd $SRC_DIR/INCHI_EXE/inchi-1/gcc
make C_COMPILER="$CC" LINKER="$CC -s"
cp $SRC_DIR/INCHI_EXE/bin/Linux/inchi-1 $PREFIX/bin/inchi-1
