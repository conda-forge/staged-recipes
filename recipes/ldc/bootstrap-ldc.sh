#!/usr/bin/env bash

#. /opt/rh/devtoolset-4/enable
#. /opt/rh/git19/enable

# clone LDC repo
cd /tmp
git clone --recursive https://github.com/ldc-developers/ldc.git -b release-0.17.1

# patch D runtime so as not to depend on newer glibc
cd /tmp/ldc/runtime/druntime
mv /tmp/d-runtime-qsort.patch .
patch -p1 < d-runtime-qsort.patch

# build and install LDC
cd /tmp/ldc
mkdir build
cd build
cmake ..
make && make install

# build and install rdmd
cd /tmp
wget -q https://raw.githubusercontent.com/D-Programming-Language/tools/2.064/rdmd.d
ldmd2 rdmd.d
cp rdmd /usr/local/bin

rm -rf /tmp/*
