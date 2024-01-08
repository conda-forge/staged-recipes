#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$CONDA_PREFIX/include"
export LDFLAGS="-L$CONDA_PREFIX/lib"

./autogen.sh
./configure --prefix=$PREFIX --disable-static
make src/espeak-ng src/speak-ng -j $CPU_COUNT prefix=$PREFIX
make prefix=$PREFIX
make install LIBDIR=$PREFIX prefix=$PREFIX
