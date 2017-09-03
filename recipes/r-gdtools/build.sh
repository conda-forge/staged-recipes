#!/bin/bash

export PKG_CFLAGS="-I$PREFIX/include/cairo -I$PREFIX/include/fontconfig -I$PREFIX/include/freetype2 -I$PREFIX/include $PKG_CFLAGS"

$R CMD INSTALL --build .
