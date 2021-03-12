#!/bin/bash

mkdir -p ${PREFIX}/lib/libsimplejson/
mkdir -p ${PREFIX}/include/libsimplejson/

make \
  CC="${CC}" \
  CXX="${CXX}" \
  dynamic
cp obj/*so  $PREFIX/lib/libsimplejson/
cp src/*\.h $PREFIX/include/libsimplejson/
cd ..

