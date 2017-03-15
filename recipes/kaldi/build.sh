#! /usr/bin/env bash

pushd src

./configure --shared --mathlib=OPENBLAS --openblas-root=${PREFIX} --fst-root=${PREFIX} --fst-version=1.6.1 --speex-root=${PREFIX} --use-cuda=no
make -j ${CPU_COUNT}

# Move binaries
find . -type f -executable -exec rsync -av --exclude *.so --exclude *.pptx --exclude *.dox --exclude README --exclude configure --exclude *.mk --exclude *.sh --exclude *.cc --exclude *.vcxproj --exclude *.h --exclude *nnet3* --exclude *online2* {} ${PREFIX}/bin \;

popd
