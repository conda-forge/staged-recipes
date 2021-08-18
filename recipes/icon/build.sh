#!/bin/env bash
echo Identify the C library that is in force
# configure for musl when present (e.g., Alpine) rather than glibc
#ldd `readlink -f $(which sh)` | grep musl
libc=$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)
echo Configure Icon build, specifying C library
if [ -z $libc ]; then
  # glibc based distribution
  echo make Configure name=linux
  make Configure name=linux
else
  # musl based distribution
  echo make Configure name=linux_musl
  make Configure name=linux_musl
fi
sed -i -e 's/CC = gcc/CC = x86_64-conda-linux-gnu-gcc/' Makedefs
echo Build Icon, run a sample of the test suite, and install upon success
make \
&& make Samples \
&& mkdir -p ${PREFIX}/usr/local \
&& mkdir -p ${PREFIX}/bin \
&& make Install dest=${PREFIX}/usr/local/icon \
&& (pushd ${PREFIX}/bin && ln -s ../usr/local/icon/bin/* .) \
&& sed -e "1,/Note Well/d" ${RECIPE_DIR}/LICENSE.txt > ${PREFIX}/usr/local/icon/LICENSE.txt
