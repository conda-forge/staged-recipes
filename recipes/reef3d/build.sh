#!/bin/sh

make -j "${CPU_COUNT}" CXX="${CXX}" LDFLAGS="${LDFLAGS}" CXXFLAGS="${CXXFLAGS}"

mkdir -p "${PREFIX}/bin"
cp bin/REEF3D "${PREFIX}/bin/reef3d"
chmod 755 "${PREFIX}/bin/reef3d"
