#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-O2 -g -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O2 -g -I$PREFIX/include $CXXFLAGS"

chmod +x configure
./configure --prefix="$PREFIX" --disable-gui --disable-ao

make -j${CPU_COUNT}
# Enable the following once https://github.com/conda/conda-build/issues/1797 is fixed.
# Enable patches/nofltk-check.patch as well
# make check -j${CPU_COUNT}
make install
