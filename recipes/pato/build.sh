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
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $PREFIX/src/volume ]; then
	mkdir -p $PREFIX/src/volume
    fi
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
    dir_gcc=$(dirname `which x86_64-conda-linux-gnu-gcc`)
    cd $dir_gcc
    files=`find . -name "x86_64-conda-linux-gnu-*" -type f`
    for x in $files
    do
	old_name=${x#"./"}
	new_name=${x#"./x86_64-conda-linux-gnu-"}
	ln -s $old_name $new_name
    done
    ls .
    cd $SRC_DIR/volume/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
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
if [ "$(uname)" = "Darwin" ]; then
    python change_lib_path_macos.py
fi
if [ "$(uname)" = "Linux" ]; then
    ldd	`which PATOx`
    echo run script change_lib_path_linux.py
    python change_lib_path_linux.py
    ldd `which PATOx`
    readelf -d `which PATOx`
fi

# Copy the source files to PREFIX
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $PREFIX/src ]; then
	mkdir -p $PREFIX/src
    fi
    cp -r $SRC_DIR/volume $PREFIX/src/volume
fi

if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $SRC_DIR/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition $PREFIX/src/environmentComposition
    # detach volume
    hdiutil detach volume
    # move pato_releases_conda.sparsebundle to $PREFIX
    cp -r pato_releases_conda.sparsebundle $PREFIX/src/pato_releases_conda.sparsebundle
fi

