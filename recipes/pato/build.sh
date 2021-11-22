#!/bin/bash
set -e  # exit when any command fails
set -x

if [ "$(uname)" = "Darwin" ]; then
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_releases_conda -fsargs -s pato_releases_conda.sparsebundle
    rm -rf volume
    mkdir volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    mv src/* volume/
    rm -rf src
    cd $SRC_DIR/volume/OpenFOAM
    tar xvf OpenFOAM-7.tar
    cd $SRC_DIR/volume/PATO
    tar xvf PATO-dev-2.3.1.tar.gz
fi
exit 0
echo -e "\n### INSTALLING PATO ###\n"
if [ "$(uname)" = "Darwin" ]; then
    # create volume
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_releases_conda -fsargs -s pato_releases_conda.sparsebundle
    rm -rf volume
    mkdir volume
    # attach volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    # move src to volume
    mv src/* volume/
    rm -rf src
    # compile gsed
    cd $SRC_DIR/volume/sed
    tar xvf sed-4.8.tar.gz
    cd $SRC_DIR/volume/sed/sed-4.8
    ./configure --prefix=$PREFIX
    make; make install
    mv $PREFIX/bin/sed $PREFIX/bin/gsed
    # get OpenFOAM src 
    cd $SRC_DIR/volume/OpenFOAM
    tar xvf OpenFOAM-7.tar
    # compile ParMGridGen
    cd $SRC_DIR/volume/OpenFOAM/dependencies/parmgridgen
    rm -rf ParMGridGen-0.0.2
    tar xvf ParMGridGen-0.0.2.tar.gz
    cd ParMGridGen-0.0.2
    make
    # compile OpenFOAM-7
    cd $SRC_DIR/volume/OpenFOAM/OpenFOAM-7
    source etc/bashrc
    ./Allwmake
    # get PATO-2.3.1
    cd $SRC_DIR/volume/PATO
    rm -rf PATO-dev-2.3.1
    tar xvf PATO-dev-2.3.1.tar.gz
    cd PATO-dev-2.3.1
    export PATO_DIR=$PWD
    source bashrc
    # Patch PATO-dev-2.3.1
    sed -ie '12 a\
    if [ "$(uname)" = "Darwin" ]; then\
       lib_name=$PATO_DIR/src/thirdParty/mutation++/install/lib/libmutation++.dylib\
       install_name_tool -id $lib_name $lib_name\
    fi\
' Allwmake
    sed -i "" -e 's/endTime_factor 1/endTime_factor 10/g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/utilities/tests/testframework/runtests_options
    sed -i "" -e 's/\$(PATO_DIR)\/install\/lib\/libPATOx.so//g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
    sed	-i "" -e 's/-I\$(LIB_PATO)\/libPATOx\/lnInclude//g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
    # Compile PATO-dev-2.3.1
    ./Allwmake
    # Move the executables and libraries to $PREFIX
    cd $SRC_DIR
    python move_exec.py
    hdiutil detach volume
fi
