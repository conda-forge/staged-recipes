#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING PATO ###\n"
if [ "$(uname)" = "Darwin" ]; then
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_releases_conda -fsargs -s pato_releases_conda.sparsebundle 
    rm -rf volume
    mkdir volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    mv src/* volume/
    cd $SRC_DIR/volume/OpenFOAM
    tar xvf OpenFOAM-7.tar
    cd $SRC_DIR/volume/OpenFOAM/dependencies/parmgridgen
    rm -rf ParMGridGen-0.0.2
    tar xvf ParMGridGen-0.0.2.tar.gz
    cd ParMGridGen-0.0.2
    make
    # [ "$(ulimit -n)" -lt "4096" ] && ulimit -n 4096 
    cd $SRC_DIR/volume/OpenFOAM/OpenFOAM-7
    source etc/bashrc
    ./Allwmake
    # cd $SRC_DIR/volume/PATO                                                                                                                                                    
    # rm -rf PATO-dev-2.3.1
    # tar xvf PATO-dev-2.3.1.tar.gz
    # cd PATO-dev-2.3.1
    # source bashrc
    # ./Allwmake  
fi
