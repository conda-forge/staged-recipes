#!/bin/bash
CSH=${BUILD_PREFIX}/bin/tcsh
sed -i 's/rl_completion_matches(text, completion_func)/rl_completion_matches(text, (rl_compentry_func_t *)completion_func)/g' textio/txInput.c
sed -i 's/extern void magicMain();/extern void magicMain(int argc, char *argv[]);/' utils/main.h
sed -i 's/completion_func !=/ (void *)completion_func != (void *)/g' textio/txInput.c
sed -i '64i typedef rl_completion_func_t CPFunction;' textio/txInput.c
sed -i 's/CPPFunction/rl_completion_func_t/g' textio/txMain.c
./configure \
    --with-tcl=${PREFIX}/lib \
    --with-tk=${PREFIX}/lib \
    --prefix="${PREFIX}"
FIX="-fpermissive -W -std=gnu89"
make database/database.h
make V=1 CFLAGS="$CFLAGS $FIX -I$PREFIX/include" CC="$CC $FIX -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make V=1 install
cd $PREFIX/bin
ln -sf wish8.6 wish
ln -sf tclsh8.6 tclsh

