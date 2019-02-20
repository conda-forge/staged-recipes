#!/usr/bin/env bash
set -eu

export LIBS="-lz"
./autogen.sh

sed -i.bak "s#/usr/bin/soapcpp2#${PREFIX}/bin/soapcpp2#g" configure
rm configure.bak

./configure \
    --prefix="${PREFIX}" \
    --with-gsoap-wsdl2h="${PREFIX}/bin/wsdl2h"

make -j1
# make -j${CPU_COUNT}
make install
