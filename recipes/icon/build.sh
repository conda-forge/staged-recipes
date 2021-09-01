#!/bin/env bash
make Configure name=linux

# Choose action based on whether gcc is available in the build environment
# To see what happens when this is not done, see
#   https://dev.azure.com/conda-forge/feedstock-builds/_build/results?buildId=370926&view=logs&j=6f142865-96c3-535c-b7ea-873d86b887bd&t=22b0682d-ab9e-55d7-9c79-49f3c3ba4823&l=637
HAVE_GCC=true
which gcc || HAVE_GCC=
if [ -z "$HAVE_GCC" ]; then
  # point make to the real gcc
  export CC=x86_64-conda-linux-gnu-gcc
  # Build Icon binaries
  make CC=${CC}
else
  # Build Icon binaries
  make
fi

# Run a small sample of the test suite
make Samples

# Install it assuming that we made it this far
mkdir -p ${PREFIX}/bin
make Install dest=${PREFIX}/icon
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)
