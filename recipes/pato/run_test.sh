#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
cd $PREFIX/src
if [ ! -d volume ]; then
    mkdir volume
fi
# attach volume
hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
source $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
export PATO_DIR=$PREFIX/src/volume/PATO/PATO-dev-2.3.1
source $PATO_DIR/bashrc
which runtests
runtests
hdiutil detach volume
sleep 20
