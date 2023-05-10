#!/bin/bash

set -exuo pipefail

# taken from section 7 of https://uwekorn.com/2020/06/14/r-arrow-for-conda-windows.html
sed -i -e 's/attribute_visible/__declspec(dllexport)/g' ${BUILD_PREFIX}/Lib/R/library/Rcpp/include/RcppCommon.h
