#!/bin/bash

export UDUNITS2_INCLUDE=${PREFIX}/include
export UDUNITS2_LIB=${PREFIX}/lib
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib

$R CMD INSTALL --build --configure-args="--with-udunits2-lib=${PREFIX}/lib --with-udunits2-include=${PREFIX}/include" .
