#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING PATO ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.     
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# create volume folders
cd $SRC_DIR
rm -rf volume
mkdir volume
if [ ! -d $PREFIX/src/volume ]; then
    mkdir -p $PREFIX/src/volume
fi

if [ "$(uname)" = "Linux" ]; then
    # move src to volume
    mv src/Linux/* volume/
    mv src/Both/* volume/
    rm -rf src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_releases_conda -fsargs -s pato_releases_conda.sparsebundle
    # attach volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    # move src to volume
    mv src/MacOS/* volume/
    mv src/Both/* volume/
    rm -rf src
    # compile gsed
    cd $SRC_DIR/volume/sed
    tar xvf sed-4.8.tar.gz
    cd $SRC_DIR/volume/sed/sed-4.8
    ./configure --prefix=$PREFIX
    make; make install
    mv $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# compile ParMGridGen
cd $SRC_DIR/volume/parmgridgen
tar xvf ParMGridGen-0.0.2.tar.gz
cd ParMGridGen-0.0.2
if [ "$(uname)" = "Linux" ]; then
    compiler=gcc
    if ! command -V $compiler &> /dev/null; then
	compiler=gcc_linux-64
    fi
    echo "using compiler=$(compiler)"
    $sed_cmd -i 's/clang/$(compiler)/g' Makefile.in
    cat Makefile.in
fi
make
cp bin/mgridgen $PREFIX/bin/mgridgen

# get OpenFOAM src
cd $SRC_DIR/volume/OpenFOAM
tar xvf OpenFOAM-7.tar
tar xvf ThirdParty-7.tar
# compile OpenFOAM-7
cd $SRC_DIR/volume/OpenFOAM/OpenFOAM-7
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
source etc/bashrc
./Allwmake

# get PATO-2.3.1
cd $SRC_DIR/volume/PATO
tar xvf PATO-dev-2.3.1.tar.gz
# Patch PATO-dev-2.3.1
$sed_cmd -i '12 a\    if [ "$(uname)" = "Darwin" ]; then' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '13 a\        lib_name=$PATO_DIR/src/thirdParty/mutation++/install/lib/libmutation++.dylib' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '14 a\        install_name_tool -id $lib_name $lib_name\n    fi' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i 's/endTime_factor \+[0-9]*/endTime_factor 15/g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/utilities/tests/testframework/runtests_options
$sed_cmd -i 's/\$(PATO_DIR)\/install\/lib\/libPATOx.so//g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/-I\$(LIB_PATO)\/libPATOx\/lnInclude//g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/==/=/g' $SRC_DIR/volume/PATO/PATO-dev-2.3.1/bashrc
# source PATO
cd PATO-dev-2.3.1
export PATO_DIR=$PWD
source bashrc
# Compile PATO-dev-2.3.1
./Allwmake

# Change the libraries paths to $PREFIX
cd $SRC_DIR
python change_lib_path.py

if [ "$(uname)" = "Darwin" ]; then
    # detach volume
    hdiutil detach volume
    # move pato_releases_conda.sparsebundle to $PREFIX
    mv pato_releases_conda.sparsebundle $PREFIX/src/pato_releases_conda.sparsebundle
fi
