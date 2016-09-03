#!/bin/bash

make config
make
# install.
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/include/

if [ `uname` == "Darwin" ]; then
  PREFIX2="build/Darwin-x86_64"
else
  PREFIX2="build/Linux-x86_64"
fi

$PREFIX2/programs/mpmetis graphs/metis.mesh 10
$PREFIX2/programs/gpmetis graphs/mdual.graph 10
$PREFIX2/programs/ndmetis graphs/mdual.graph 10
$PREFIX2/programs/gpmetis graphs/test.mgraph 10
$PREFIX2/programs/m2gmetis graphs/metis.mesh 10

cp $PREFIX2/libmetis/libmetis.a $PREFIX/lib/
cp $PREFIX2/programs/cmpfillin $PREFIX/bin/
cp $PREFIX2/programs/gpmetis $PREFIX/bin/
cp $PREFIX2/programs/graphchk $PREFIX/bin/
cp $PREFIX2/programs/m2gmetis $PREFIX/bin/
cp $PREFIX2/programs/ndmetis $PREFIX/bin/
cp $PREFIX2/programs/mpmetis $PREFIX/bin/
cp include/metis.h $PREFIX/include/
