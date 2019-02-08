#!/bin/bash

# conda-forge/conda-forge.github.io#621
find ${PREFIX} -name "*.la" -delete

./configure \
  --prefix=${PREFIX} \
  --without-doxygen \
  --with-html-dir=$(pwd)/tmphtml

make -j ${CPU_COUNT}
make -j ${CPU_COUNT} install
