#!/bin/sh

make -j "${CPU_COUNT}" CXX="${CXX}"

mkdir -p "${PREFIX}/bin"
cp bin/REEF3D "${PREFIX}/bin/reef3d"
chmod 755 "${PREFIX}/bin/reef3d"
