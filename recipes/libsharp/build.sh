#!/bin/bash

# Build the C library first

autoconf
./configure --enable-openmp --enable-noisy-make --enable-pic
make -j${CPU_COUNT}
make test

# Do the install by hand (not included in package)
cp -r auto/include/* ${PREFIX}/include
cp -r auto/lib/* ${PREFIX}/lib

# Now build the python lib
export LIBSHARP=${PREFIX}
cd python
${PYTHON} -m pip install . --no-deps --ignore-installed -v
