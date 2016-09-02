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

cd Graphs
./kmetis 4elt.graph 40
./onmetis 4elt.graph
./pmetis test.mgraph 2
./kmetis test.mgraph 2
./kmetis test.mgraph 5
./partnmesh metis.mesh 10
./partdmesh metis.mesh 10
./mesh2dual metis.mesh
./kmetis metis.mesh.dgraph 10
cd ..

cp $PREFIX2/libmetis/libmetis.a $PREFIX/lib/
cp $PREFIX2/programs/cmpfillin $PREFIX/bin/
cp $PREFIX2/programs/gpmetis $PREFIX/bin/
cp $PREFIX2/programs/graphchk $PREFIX/bin/
cp $PREFIX2/programs/m2gmetis $PREFIX/bin/
cp $PREFIX2/programs/ndmetis $PREFIX/bin/
cp $PREFIX2/programs/mpmetis $PREFIX/bin/
cp include/metis.h $PREFIX/include/
