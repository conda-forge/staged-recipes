#!/bin/bash
set -euxo pipefail

# shellcheck disable=SC2086  # CMAKE_ARGS holds several arguments
cmake -S test -B build-test -G Ninja ${CMAKE_ARGS:-} -DCMAKE_PREFIX_PATH="${PREFIX}"
cmake --build build-test
cd build-test
./test_sz3
./test_h5z

# The plugin copy is in HDF5's default plugin directory, so HDF5 finds it with HDF5_PLUGIN_PATH unset.
unset HDF5_PLUGIN_PATH
h5repack -f UD=32024,0 plain.h5 repacked.h5
# h5repack exits 0 and writes an unfiltered copy when it cannot load the filter, so look for it.
h5dump -pH repacked.h5 | tee dump.txt
grep -q 32024 dump.txt
h5repack -f NONE repacked.h5 restored.h5
h5diff -d 1e-3 plain.h5 restored.h5
