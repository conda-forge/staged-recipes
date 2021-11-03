#!/bin/bash
set -e  # exit when any command fails

echo -e "\n### INSTALLING PATO ###\n"
rm -rf volume
mkdir volume
hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
cat volume/README.md
cd $SRC_DIR/volume/OpenFOAM/dependencies/parmgridgen
tar xvf ParMGridGen-0.0.2.tar.gz
cd ParMGridGen-0.0.2
make
cd $SRC_DIR/volume/OpenFOAM/OpenFOAM-7
source etc/bashrc
./Allwmake
