#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# conda-forge/conda-forge.github.io#621
find ${PREFIX} -name "*.la" -delete

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"
export GSTLAL_LIBS="-L${PREFIX}/lib -lgstlal -lgstlaltags -lgstlaltypes"
export framecpp_CFLAGS=" "

# configure
${SRC_DIR}/configure \
  --prefix=${PREFIX} \
  --with-doxygen=no \
  --with-framecpp=yes \
  --with-gds=no \
  --with-html-dir=$(pwd)/tmphtml \
  --with-nds=yes \
;

# build
make -j ${CPU_COUNT} V=1 VERBOSE=1

# install
make -j ${CPU_COUNT} V=1 VERBOSE=1 install

# test
if [ "$(uname)" == "Linux" ]; then
  make -j ${CPU_COUNT} V=1 VERBOSE=1 check
fi
