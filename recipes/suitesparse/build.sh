#!/bin/bash

if [ "$(uname)" == "Darwin" ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    cp -f "${RECIPE_DIR}/SuiteSparse_config_Mac.mk" SuiteSparse_config/SuiteSparse_config.mk
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
    cp -f "${RECIPE_DIR}/SuiteSparse_config_linux.mk" SuiteSparse_config/SuiteSparse_config.mk
fi


export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export INSTALL_LIB="${PREFIX}/lib"
export INSTALL_INCLUDE="${PREFIX}/include"

export BLAS="-lopenblas"
export LAPACK="-lopenblas"

eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make -j1
make install
