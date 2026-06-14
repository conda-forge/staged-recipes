#!/bin/bash
export R_HIGHS_LIB_DIR="${PREFIX}/lib"
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
