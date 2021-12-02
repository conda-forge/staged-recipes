#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

if [ "$(uname)" = "Darwin" ]; then
    # to be removed - testing 
    ls $PREFIX/src

    # copy environmentComposition
    cp $PREFIX/src/environmentComposition $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
    rm -f $PREFIX/src/environmentComposition
fi

# to be removed - testing
ls $PREFIX/src/volume
echo environmentComposition 1
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition

echo -e "\n### TESTING PATO ###\n"
# source OpenFOAM and PATO
source $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
export PATO_DIR=$PREFIX/src/volume/PATO/PATO-dev-2.3.1
source $PATO_DIR/bashrc
# run tests
which runtests
runtests
