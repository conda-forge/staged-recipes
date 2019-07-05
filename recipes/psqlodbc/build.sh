#!/bin/bash

set -euo pipefail

./configure --prefix=$PREFIX --with-libpq=$PREFIX/lib --enable-pthreads
make -j${CPU_COUNT}
make install
# generate the driver inst files
python $RECIPE_DIR/generate_odbc_inst_template.py
