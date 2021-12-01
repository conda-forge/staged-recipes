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
echo environmentComposition 1
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
source $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
echo environmentComposition 2
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
export PATO_DIR=$PREFIX/src/volume/PATO/PATO-dev-2.3.1
echo environmentComposition 3
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
source $PATO_DIR/bashrc
echo environmentComposition 4
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
which runtests
runtests
echo environmentComposition 5
cat $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
hdiutil detach volume
