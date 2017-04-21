#!/bin/bash

mkdir -p $PREFIX/lib/dmd/src/phobos/
cd $SRC_DIR/src/phobos
cp -r * $PREFIX/lib/dmd/src/phobos/

mkdir -p $PREFIX/lib/dmd/src/druntime/import/
cd $SRC_DIR/src/druntime/import
cp -r * $PREFIX/lib/dmd/src/druntime/import/

mkdir -p $PREFIX/lib/dmd/linux/lib64/
cd $SRC_DIR/linux/lib64/
cp -r * $PREFIX/lib/dmd/linux/lib64/

mkdir -p $PREFIX/bin
cd $SRC_DIR/linux/bin64/

chmod a+x ddemangle dman dmd dumpobj dustmite obj2asm rdmd
cp ddemangle dman dmd dumpobj dustmite obj2asm rdmd $PREFIX/bin
