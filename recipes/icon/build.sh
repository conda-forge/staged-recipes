#!/bin/env bash
make Configure name=linux
sed -i -e 's/CC = gcc/CC = x86_64-conda-linux-gnu-gcc/' Makedefs
echo Build Icon, run a sample of the test suite, and install upon success
make
make Samples
&& mkdir -p ${PREFIX}/usr/local \
&& mkdir -p ${PREFIX}/bin \
&& make Install dest=${PREFIX}/usr/local/icon \
&& (pushd ${PREFIX}/bin && ln -s ../usr/local/icon/bin/* .) \
&& sed -e "1,/Note Well/d" ${RECIPE_DIR}/LICENSE.txt > ${PREFIX}/usr/local/icon/LICENSE.txt
