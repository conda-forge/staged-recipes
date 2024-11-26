#!/bin/bash

# https://stackoverflow.com/questions/72635283/how-to-create-conda-package-for-a-tool

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar

set -x

mkdir -p $PREFIX/bin

g++ --version
gcc --version

autoreconf -i
echo "jani debug autoreconf -i"
pwd

mkdir Darwin

echo "jani debug mkdir"
pwd

cd Darwin
echo "jani debug CD"
pwd


../configure
echo "jani debug configure"
echo $SRC_DIR
pwd
ls

make
echo "jani debug make"
pwd

cp autogrid4 $PREFIX/bin
