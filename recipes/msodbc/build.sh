#!/bin/bash

set -ex

mkdir build
pushd build

tar -xvf ../data.tar.xz

cp opt/microsoft/msodbcsql*/etc/odbcinst.ini $PREFIX/etc
cp opt/microsoft/msodbcsql*/include/msodbcsql.h $PREFIX/include
cp opt/microsoft/msodbcsql*/lib64/libmsodbcsql* $PREFIX/lib
cp -r ./usr/share/doc $PREFIX/share

ln -s $PREFIX/lib/libmsodbcsql*.so.* $PREFIX/lib/libmsodbcsql.so
popd
