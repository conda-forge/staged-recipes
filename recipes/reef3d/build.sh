#!/bin/sh

make -j "${CPU_COUNT}" CXX="mpicxx" HYPRE_DIR="${PREFIX}" EIGEN_DIR="${PREFIX}/include/eigen3"

mkdir -p "${PREFIX}/bin"
cp bin/REEF3D "${PREFIX}/bin/reef3d"
chmod 755 "${PREFIX}/bin/reef3d"
