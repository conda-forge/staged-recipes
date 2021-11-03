#!/bin/bash
set -e  # exit when any command fails
set +x

echo -e "\n### INSTALLING PATO ###\n"
if [ "$(uname)" = "Darwin" ]; then
    rm -rf volume
    mkdir volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    cat volume/README.md
    cd $SRC_DIR/volume/OpenFOAM/dependencies/parmgridgen
    rm -rf ParMGridGen-0.0.2
    tar xvf ParMGridGen-0.0.2.tar.gz
    cd ParMGridGen-0.0.2
    make
    [ "$(ulimit -n)" -lt "4096" ] && ulimit -n 4096 
    cd $SRC_DIR/volume/OpenFOAM/OpenFOAM-7
    source etc/bashrc
    ./Allwmake
fi
