#!/bin/bash
export DISABLE_AUTOBREW=1

# Check if we are cross-compiling
if [ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]; then
    R CMD INSTALL --build --no-test-load . ${R_ARGS}
else
    R CMD INSTALL --build . ${R_ARGS}
fi
