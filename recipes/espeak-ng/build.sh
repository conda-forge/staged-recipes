#!/bin/bash
set -euo pipefail

./autogen.sh
[[ "$target_platform" == "win-64" ]] && export CPPFLAGS="-I$(realpath $SRC_DIR)/src/windows -I$(realpath $CONDA_PREFIX/include) -I$(realpath $CONDA_PREFIX)/Library/include -I$(realpath $SRC_DIR)/src/include"
[[ "$target_platform" == "win-64" ]] && export LDFLAGS="-L$(realpath $LIBRARY_LIB) -L$(realpath $CONDA_PREFIX/Library/lib)" 
LD=$LD ./configure --prefix=$(realpath $PREFIX) --disable-static
make src/espeak-ng src/speak-ng -j $CPU_COUNT prefix=$PREFIX
make prefix=$(realpath $PREFIX)
make install prefix=$PREFIX
