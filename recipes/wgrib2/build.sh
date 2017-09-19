#!/bin/bash

export CC="gcc"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib $LDFLAGS"
export CFLAGS="-fPIC $CFLAGS"
export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"

rm -rf g2clib-* wgrib2/{fnlist,Gctpc,gctpc_ll2xy,new_grid_lambertc}.[ch]
cp $RECIPE_DIR/config.h wgrib2/config.h

cd wgrib2
export CFLAGS="-I.. -fopenmp"
export LDFLAGS="-lgrib2c -ljasper -lnetcdf -lpng -lmysqlclient -lz -lm -fopenmp"
make fnlist.h fnlist.c
make

cp wgrib2 $PREFIX/bin
