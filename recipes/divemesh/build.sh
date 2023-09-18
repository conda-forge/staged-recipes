#!/bin/sh

make -j "${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
cp bin/DIVEMesh "${PREFIX}/bin/divemesh"
chmod 755 "${PREFIX}/bin/divemesh"