#!/bin/bash
export DISABLE_AUTOBREW=1
#export TORCH_HOME=${SP_DIR}/torch/lib
#export LIBRARY_PATH=${SP_DIR}/torch/lib:${LIBRARY_PATH}
export TORCH_INSTALL=1
${R} -e "options(repos=c(CRAN='https://cloud.r-project.org')); source('tools/buildlantern.R')"
${R} CMD INSTALL --build . ${R_ARGS}
