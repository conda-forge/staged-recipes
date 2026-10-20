#!/bin/bash
set -euo pipefail
# configure finds the conda layout under CUDA_HOME: targets/<arch>/include
# for the headers and lib/ for the libraries
export CUDA_HOME="${PREFIX}"
export DISABLE_AUTOBREW=1
# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS:-}
