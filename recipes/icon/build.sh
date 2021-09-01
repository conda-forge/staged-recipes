#!/bin/env bash
make Configure name=linux

# Choose action based on whether gcc is available in the build environment
#   To see what happens when this is not done, see https://dev.azure.com/conda-forge/feedstock-builds/_build/results?buildId=365071&view=logs&jobId=35904a6b-5404-55c5-26d9-f2fb250157bf&j=35904a6b-5404-55c5-26d9-f2fb250157bf&t=f869e631-70a1-522d-dae3-fa8b231d712d
### which gcc
### if [ *? ]; then
###   # point make to the real gcc
###   export CC=x86_64-conda-linux-gnu-gcc
###   # Build Icon binaries
###   make CC=${CC}
### else
###   # Build Icon binaries
###   make
### fi
make
# Run a small sample of the test suite
make Samples
# Install it assuming that we made it this far
mkdir -p ${PREFIX}/bin
make Install dest=${PREFIX}/icon
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)
