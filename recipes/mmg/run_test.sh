#!/bin/bash
set -e

find $PREFIX -name libElas.so
find $PREFIX -name mmg2d_O3
which mmg2d_O3
ldd $PREFIX/bin/mmg2d_O3
ls -lha $PREFIX/lib

#mmg2d_O3 --version
#mmgs_O3 --version
#mmg3d_O3 --version