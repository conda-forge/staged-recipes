#!/usr/bin/env bash

set -xe

make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/{include,lib}

install -m 644 build/lib/libolbcore.so ${PREFIX}/lib/

# copy the header files
DEST=${PREFIX}/include/openlb

mkdir -p $DEST

pushd src

for h in $(find ./ -name "*.h" -or -name "*.hh"); do
  dir_name=$(dirname $h)
  mkdir -p ${DEST}/${dir_name}
  cp ${h} ${DEST}/${dir_name}/
done

popd
