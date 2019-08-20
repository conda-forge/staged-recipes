#!/bin/bash

set -x

cat > site.cfg <<EOF
[DEFAULT]
libraries = 
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include
EOF

export NPY_BLAS_ORDER=,
export NPY_LAPACK_ORDER=,

# Internal compiler error with gcc 7
if [[ "${target_platform}" == "linux-aarch64" ]]; then
    export CC="$BUILD_PREFIX/bin/clang"
    export CXX="$BUILD_PREFIX/bin/clang++"
fi

$PYTHON -m pip install --no-deps --ignore-installed -v .
