#!/bin/bash


# Build
make -j1

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

# Install everything manually.
mv libmetis.a "${PREFIX}/bin/libmetis.a"
mv graphchk "${PREFIX}/bin/graphchk"
mv kmetis "${PREFIX}/bin/kmetis"
mv mesh2dual "${PREFIX}/bin/mesh2dual"
mv mesh2nodal "${PREFIX}/bin/mesh2nodal"
mv oemetis "${PREFIX}/bin/oemetis"
mv onmetis "${PREFIX}/bin/onmetis"
mv partdmesh "${PREFIX}/bin/partdmesh"
mv partnmesh "${PREFIX}/bin/partnmesh"
mv pmetis "${PREFIX}/bin/pmetis"
