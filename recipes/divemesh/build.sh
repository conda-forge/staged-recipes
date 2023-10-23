#!/bin/sh

make -j "${CPU_COUNT}" CXX="${CXX}"

mkdir -p "${PREFIX}/bin"
cp bin/DiveMESH "${PREFIX}/bin/divemesh"
chmod 755 "${PREFIX}/bin/divemesh"
