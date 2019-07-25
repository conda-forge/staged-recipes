#!/bin/bash

# remove ncurses tic.h that conficts with astrometry tic.h
rm -f $CONDA_PREFIX/include/tic.h
rm -f $PREFIX/include/tic.h

export CFITS_INC="-I$PREFIX/include"
export CFITS_LIB="-L$PREFIX/lib -lcfitsio -lm"
export NETPBM_INC="-I$PREFIX/include"
export NETPBM_LIB="-L$PREFIX/lib -lnetpbm"
export CAIRO_INC="-I$PREFIX/include -I$PREFIX/include/cairo"
export CAIRO_LIB="-L$PREFIX/lib -lcairo"
export PNG_INC="-I$PREFIX/include"
export PNG_LIB="-L$PREFIX/lib -lpng16"
export JPEG_INC="-I$PREFIX/include"
export JPEG_LIB="-L$PREFIX/lib -ljpeg"
export ZLIB_INC="-I$PREFIX/include"
export ZLIB_LIB="-L$PREFIX/lib -lz"

make
make extra
make install INSTALL_DIR="$PREFIX"
