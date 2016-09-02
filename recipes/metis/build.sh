#!/bin/bash

make

# Run tests.
pushd Graphs
# Use mtest
./mtest 4elt.graph
#./mtest metis.mesh
./mtest test.mgraph

# Try some example programs.
../kmetis 4elt.graph 40
../onmetis 4elt.graph
../pmetis test.mgraph 2
../kmetis test.mgraph 2
../kmetis test.mgraph 5
../partnmesh metis.mesh 10
../partdmesh metis.mesh 10
../mesh2dual metis.mesh
../kmetis metis.mesh.dgraph 10

popd

# install.
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/include/

cp libmetis.a $PREFIX/lib/
cp graphchk $PREFIX/bin/
cp partnmesh $PREFIX/bin/
cp kmetis $PREFIX/bin/
cp mesh2dual $PREFIX/bin/
cp mesh2nodal $PREFIX/bin/
cp oemetis $PREFIX/bin/
cp onmetis $PREFIX/bin/
cp partdmesh $PREFIX/bin/
cp pmetis $PREFIX/bin/
cp Graphs/mtest $PREFIX/bin/
cp Lib/*.h $PREFIX/include/
