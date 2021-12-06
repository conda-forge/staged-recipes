#!/bin/bash

set -x

make DCOMPILER=ldc2
make test-nobuild DCOMPILER=ldc2

for fname in $(ls bin/*); do
  readelf -d ${fname}
  patchelf --set-rpath '$PREFIX/lib' ${fname}
  readelf -d ${fname}
done
cp -r bin $PREFIX
