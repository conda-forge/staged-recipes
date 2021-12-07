#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

cd $PREFIX/src
if [ "$(uname)" = "Linux" ]; then
    tar xvf volume.tar
fi
if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $PREFIX/src/environmentComposition $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
    rm -f $PREFIX/src/environmentComposition
fi

echo -e "\n### TESTING PATO ###\n"
# source OpenFOAM and PATO
source $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
export PATO_DIR=$PREFIX/src/volume/PATO/PATO-dev-2.3.1
source $PATO_DIR/bashrc
# run tests
which runtests
runtests

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
