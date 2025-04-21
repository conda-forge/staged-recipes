#!/bin/bash
set -ex

cmake ${CMAKE_ARGS} \
      -DMUMPS_DIR=$PREFIX/lib \
      -DSCALAPACK_LIBRARIES=$PREFIX/lib/libscalapack.so \
      -DCONAN_LIB_DIRS_TCL=$PREFIX/lib \
      -DOPENMPI=TRUE \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive -isystem $PREFIX/include/eigen3" \
      -DCMAKE_CXX_STANDARD_LIBRARIES="-L$PREFIX/lib -lesmumps -lscotch -lscotcherr -lscotchmetisv5 -lmetis -lhdf5 -lhdf5_hl -ltcl8.6 $PREFIX/lib/libz.so.1 $PREFIX/lib/libdmumps.a" \
      -S . -B build

cmake --build ./build --config Release --target OpenSees   --parallel $CPU_COUNT
cmake --build ./build --config Release --target OpenSeesPy --parallel $CPU_COUNT
cmake --build ./build --config Release --target OpenSeesSP --parallel $CPU_COUNT
cmake --build ./build --config Release --target OpenSeesMP --parallel $CPU_COUNT

cmake --install ./build --verbose
cp ./build/OpenSeesPy.so $SP_DIR/opensees.so
cp ./build/OpenSeesSP $PREFIX/bin
cp ./build/OpenSeesMP $PREFIX/bin

#cp -r EXAMPLES $PREFIX/share/
