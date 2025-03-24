#!/bin/bash

cp LICENSE.txt ${PREFIX}

mkdir build
cd build

declare -a CMAKE_LIBXML_LIBRARY
if [[ ${target_platform} == osx-*64 ]]; then
  CMAKE_LIBXML_LIBRARY+=(-DLIBXML_LIBRARY="${PREFIX}"/lib/libxml2.dylib)
elif [[ ${target_platform} == linux-*64 ]]; then
  CMAKE_LIBXML_LIBRARY+=(-DLIBXML_LIBRARY="${PREFIX}"/lib/libxml2.so)
fi

cmake ${CMAKE_ARGS} \
      -DCMAKE_CXX_STANDARD_LIBRARIES=-lxml2 \
      -DWITH_SWIG=OFF \
      "${CMAKE_LIBXML_LIBRARY[@]}" \
      -DLIBXML_INCLUDE_DIR=${PREFIX}/include/libxml2 \
      -DENABLE_COMP=ON \
      -DENABLE_FBC=ON \
      -DENABLE_GROUPS=ON \
      -DENABLE_LAYOUT=ON \
      -DENABLE_MULTI=ON \
      -DENABLE_QUAL=ON \
      -DENABLE_RENDER=ON \
      -DENABLE_DISTRIB=ON \
      -DENABLE_ARRAYS=ON \
      -DENABLE_DYN=ON \
      -DENABLE_REQUIREDELEMENTS=ON \
      -DENABLE_SPATIAL=ON \
      -DWITH_CPP_NAMESPACE=ON \
      ..
make -j"${CPU_COUNT}"
make install
