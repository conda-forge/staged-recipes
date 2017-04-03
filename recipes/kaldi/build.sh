#! /usr/bin/env bash

pushd src

./configure --shared --mathlib=OPENBLAS --openblas-root=${PREFIX} --fst-root=${PREFIX} --fst-version=1.6.1 --speex-root=${PREFIX} --use-cuda=no
make -j ${CPU_COUNT}

# Move binaries
find . -type f -executable -regex '.*bin/.*' -exec cp {} ${PREFIX}/bin \;

popd
