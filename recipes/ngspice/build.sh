#!/bin/bash

set -x

# Used by autotools AX_PROG_CC_FOR_BUILD
export CC_FOR_BUILD=${CC}

./autogen.sh

configure_args=(
  --prefix=${PREFIX}
  --enable-xspice
  --disable-debug
  --enable-cider
  --with-readline=yes
  --enable-openmp

  # Not enabled for now:
  #  --enable-adms
)


#
# build libngspice.dylib
#
mkdir release-lib && cd release-lib
../configure "${configure_args[@]}" --with-ngshared
make
make install
cd -


#
# build ngspice executable
#
mkdir release-bin && cd release-bin
../configure "${configure_args[@]}" --with-x
make
make install
cd -
