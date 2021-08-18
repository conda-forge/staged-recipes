#!/bin/env bash
make Configure name=linux
# there should be a better way than Makedefs hacking with sed...
sed -i -e 's/CC = gcc/CC = x86_64-conda-linux-gnu-gcc/' Makedefs
echo Build Icon, run a sample of the test suite, and install upon success
make
make Samples
mkdir -p ${PREFIX}/bin
make Install dest=${PREFIX}/icon
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)
sed -e "1,/Note Well/d" ${RECIPE_DIR}/LICENSE.txt > ${PREFIX}/LICENSE.txt
