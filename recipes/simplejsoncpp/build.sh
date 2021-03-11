#!/bin/bash

mkdir -p ${PREFIX}/include/simplejsoncpp/
mkdir -p ${PREFIX}/lib/simplejsoncpp/

make \
  CXX="${CXX}" \
  dynamic
cp obj/*so  $PREFIX/lib/simplejsoncpp/
cp src/*\.h $PREFIX/include/simplejsoncpp/
cd ..

