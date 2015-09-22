#!/bin/bash


# Problems with cartopy if the -m{32,64} flag is not defined.
# See https://taskman.eionet.europa.eu/issues/14817.

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  ARCH="-m64"
else
  ARCH="-m32"
fi

CFLAGS=${ARCH} CPPFLAGS=${ARCH} CXXFLAGS=${ARCH} LDFLAGS=${ARCH} FFLAGS=${ARCH} \
    ./configure --prefix=$PREFIX --without-jni

make
make install
