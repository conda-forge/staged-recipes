#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
if [ ! -d volume ]; then
    mkdir volume
fi
# attach volume
hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
source $SRC_DIR/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
export PATO_DIR=$SRC_DIR/volume/PATO/PATO-dev-2.3.1
source $PATO_DIR/bashrc
echo ls $PATO_TUTORIALS
ls $PATO_TUTORIALS
echo ls $WM_PROJECT_DIR
ls $WM_PROJECT_DIR
which runtests
runtests
hdiutil detach volume
