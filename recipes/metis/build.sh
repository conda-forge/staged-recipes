#!/bin/bash

make

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


