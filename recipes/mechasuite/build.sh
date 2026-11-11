#!/bin/bash
#
set -e

# ---- install python library ----
cd $SRC_DIR
#cd mechasuite
#pip install . --no-deps --no-build-isolation --prefix="$PREFIX"
$PYTHON -m pip install . --no-deps  --no-build-isolation --prefix="$PREFIX"
#cd ..

# ---- build Qt app ----
cd mechaedit
qmake  PREFIX="$PREFIX"
make
make install
