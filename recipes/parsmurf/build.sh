#!/bin/sh


echo $PREFIX
echo `pwd`


cmake src
make -j 4

echo `ls`

#cmake src -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON

cp parSMURF1 $PREFIX/
