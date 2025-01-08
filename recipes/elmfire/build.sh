#!/bin/bash

set -ex

# Need to drop gfortran flags for OSX
if [[ ${target_platform} =~ .*osx.* ]]; then
  sed -i 's/ -unroll//' ${SRC_DIR}/build/linux/Makefile_elmfire
fi

cd build/linux && ./make_gnu.sh
cp bin/elmfire_$ELMFIRE_VERSION $PREFIX/bin/elmfire
