#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# conda-forge/conda-forge.github.io#621
#find ${PREFIX} -name "*.la" -delete

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"
export GSTLAL_LIBS="-L${PREFIX}/lib -lgstlal -lgstlaltags -lgstlaltypes"

# configure
${SRC_DIR}/configure \
  --disable-massmodel \
  --prefix=${PREFIX} \
  --without-doxygen \
  --with-html-dir=$(pwd)/html \
;

# build
export CPU_COUNT="1"
make -j ${CPU_COUNT} V=1 VERBOSE=1

# install
make -j ${CPU_COUNT} V=1 VERBOSE=1 install
