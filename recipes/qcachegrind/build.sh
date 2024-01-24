#!/bin/bash

mkdir build
cd build

if [[ ${target_platform} =~ .*linux.* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi
# -early is needed here to avoid qmake attempting to run g++
qmake -early ../qcg.pro \
        QMAKE_CXX=${CXX}                   \
        QMAKE_LINK=${CXX}                  \
        QMAKE_CXXFLAGS="${CXXFLAGS}"       \
        QMAKE_LFLAGS="${LDFLAGS}"
make -j${CPU_COUNT}

for target in cgview qcachegrind; do
  if [[ ${target_platform} == osx-64 ]]; then
    cp ${target}/${target}.app/Contents/MacOS/${target} ${PREFIX}/bin/
  else
    cp ${target}/${target} ${PREFIX}/bin/
  fi
done
