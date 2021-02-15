#!/bin/bash
export DISABLE_AUTOBREW=1
DISPLAY=${DISPLAY:-:0} $R CMD INSTALL --build . ${R_ARGS}
