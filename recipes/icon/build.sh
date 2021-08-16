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
echo Build Icon, run a sample of the test suite, and install upon success
#TRUE_PREFIX=$(echo $PREFIX | sed -e 's/\/_h_env_placehold.*//')
TRUE_PREFIX=$PREFIX
readlink -f $TRUE_PREFIX
make \
&& make Samples \
&& mkdir -p ${TRUE_PREFIX}/usr/local \
&& mkdir -p ${TRUE_PREFIX}/bin \
&& make Install dest=${TRUE_PREFIX}/usr/local/icon \
&& (pushd ${TRUE_PREFIX}/bin && ln -s ../usr/local/icon/bin/* .)

