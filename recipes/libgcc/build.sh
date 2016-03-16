#!/bin/bash

if [ $ARCH == 32 ]; then
  ARCH=""
fi

# This is meant to be run on a docker image where gcc is installed to /usr/local
SRC=/usr/local/lib${ARCH}
DST=$PREFIX/lib

mkdir $DST
cd $DST

cp $SRC/libgcc_s.so.1 .
ln -s   libgcc_s.so.1 libgcc_s.so

cp $SRC/libgomp.so.1.0.0 .
ln -s   libgomp.so.1.0.0 libgomp.so
ln -s   libgomp.so.1.0.0 libgomp.so.1

cp $SRC/libstdc++.so.6.0.21 .
ln -s   libstdc++.so.6.0.21 libstdc++.so
ln -s   libstdc++.so.6.0.21 libstdc++.so.6

cp $SRC/libgfortran.so.3.0.0 .
ln -s   libgfortran.so.3.0.0 libgfortran.so.3
ln -s   libgfortran.so.3.0.0 libgfortran.so

cp $SRC/libquadmath.so.0.0.0 .
ln -s   libquadmath.so.0.0.0 libquadmath.so
ln -s   libquadmath.so.0.0.0 libquadmath.so.0
