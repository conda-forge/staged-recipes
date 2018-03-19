#!/bin/bash
set -xeuo pipefail

export HALIDE_DISTRIB_PATH=$PREFIX
export LIBHALIDE=$PREFIX/lib/libHalide$SHLIB_EXT
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

cd python_bindings
make -j${CPU_COUNT}

# install the module
cp bin/halide*.so "$SP_DIR/"
