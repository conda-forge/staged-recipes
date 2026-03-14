#!/bin/bash
export DISABLE_AUTOBREW=1

# Avoid pkg-config --static for libtiff here; it pulls in private deps and
# causes conda-build overlinking failures.
export INCLUDE_DIR="${PREFIX}/include"
export LIB_DIR="${PREFIX}/lib"

${R} CMD INSTALL --build . ${R_ARGS}
