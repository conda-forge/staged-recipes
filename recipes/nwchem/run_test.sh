#!/bin/bash -f
set -x

if [[ "$mpi" == "openmpi" ]]; then
    export OMPI_MCA_plm_rsh_agent=sh
fi

export NWCHEM_TOP=$SRC_DIR
export NWCHEM_EXECUTABLE=$PREFIX/bin/nwchem
export NWCHEM_TARGET=""
export MPIRUN_PATH=$PREFIX/bin/mpirun 
# nwchem cannot deal with path lengths >255 characters
#export NWCHEM_BASIS_LIBRARY=$PREFIX/share/nwchem/libraries/
export NWCHEM_BASIS_LIBRARY=$SRC_DIR/src/basis/libraries/

cd $NWCHEM_TOP/QA
./doafewqmtests.mpi 2

# just checking...
perl nwparse.pl testoutputs/h2o_opt.out

cat $NWCHEM_TOP/QA/testoutputs/h2o_opt.out
