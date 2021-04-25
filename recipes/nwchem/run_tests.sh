#!/bin/bash -f

export NWCHEM_TOP=$SRC_DIR/nwchem-6.8
export NWCHEM_EXECUTABLE=$PREFIX/bin/nwchem
export NWCHEM_TARGET=""
export MPIRUN_PATH=$PREFIX/bin/mpirun 
export NWCHEM_BASIS_LIBRARY=$PREFIX/share/nwchem/libraries/

cd $NWCHEM_TOP/QA
./doafewqmtests.mpi 4
