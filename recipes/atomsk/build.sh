#!/bin/bash
export LAPACK=$PREFIX/lib/liblapack${SHLIB_EXT}
cd src
make atomsk
cp atomsk $PREFIX/bin/atomsk
