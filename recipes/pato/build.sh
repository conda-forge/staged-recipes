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

# create volume folder
if [ ! -d $PREFIX/src/volume ]; then
    mkdir -p $PREFIX/src/volume
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume
    mv $SRC_DIR/src/Linux/* $PREFIX/src/volume/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume/
    rm -rf $SRC_DIR/src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_releases_conda -fsargs -s pato_releases_conda.sparsebundle
    # attach volume
    hdiutil attach -mountpoint volume pato_releases_conda.sparsebundle
    # move src to volume
    mv $SRC_DIR/src/MacOS/* $PREFIX/src/volume/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume/
    rm -rf $SRC_DIR/src
    mv $SRC_DIR/change_lib_path_macos.py $PREFIX/src/
    # compile gsed
    cd $PREFIX/src/volume/sed
    tar xvf sed-4.8.tar.gz
    cd $PREFIX/src/volume/sed/sed-4.8
    ./configure --prefix=$PREFIX
    make; make install
    mv $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# compile ParMGridGen
cd $PREFIX/src/volume/parmgridgen
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
    cd $PREFIX/src/volume/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    $sed_cmd -i "s/COPTIONS =/COPTIONS = -fPIC/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
fi
make
cp bin/mgridgen $PREFIX/bin/mgridgen
cp MGridGen/IMlib/libIMlib.a .
cp libmgrid.a libMGridGen.a

# get OpenFOAM src
cd $PREFIX/src/volume/OpenFOAM
tar xvf OpenFOAM-7.tar
tar xvf ThirdParty-7.tar
# compile OpenFOAM-7
export WM_NCOMPPROCS=`nproc` # parallel build
cd $PREFIX/src/volume/OpenFOAM/OpenFOAM-7
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
source etc/bashrc
./Allwmake -j

# get foam-extend src
cd $PREFIX/src/volume/foam-extend
tar xvf foam-extend-4.1_for_openfoam-7.tar
# compile foam-extend 4.1
cd $PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7/etc
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
echo "#!/bin/bash" > $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "set -e" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "set -x" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "cp prefs.sh-build prefs.sh # using PREFIX" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "set +e" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "source \$PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "source bashrc" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "set -e" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "cp prefs.sh-run prefs.sh # using CONDA_PREFIX" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "cd $PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
echo "./Allwmake -j" >> $SRC_DIR/build_foam-extend_for_openfoam.sh
chmod +x $SRC_DIR/build_foam-extend_for_openfoam.sh
$SRC_DIR/build_foam-extend_for_openfoam.sh

# get PATO-2.3.1
cd $PREFIX/src/volume/PATO
tar xvf PATO-dev-2.3.1.tar.gz
# Patch PATO-dev-2.3.1
$sed_cmd -i '12 a\    if [ "$(uname)" = "Darwin" ]; then' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '13 a\        lib_name=$PATO_DIR/src/thirdParty/mutation++/install/lib/libmutation++.dylib' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '14 a\        install_name_tool -id $lib_name $lib_name\n    fi' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i 's/endTime_factor \+[0-9]*/endTime_factor 15/g' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/src/applications/utilities/tests/testframework/runtests_options
$sed_cmd -i 's/\$(PATO_DIR)\/install\/lib\/libPATOx.so//g' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/-I\$(LIB_PATO)\/libPATOx\/lnInclude//g' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/==/=/g' $PREFIX/src/volume/PATO/PATO-dev-2.3.1/bashrc
# source PATO
cd PATO-dev-2.3.1
export PATO_DIR=$PWD
source bashrc
# Compile PATO-dev-2.3.1
./Allwmake

# Change the libraries paths to $PREFIX
cd $PREFIX/src
export SRC_DIR=$PWD # for the python scripts
if [ "$(uname)" = "Darwin" ]; then
    python change_lib_path_macos.py
    rm -f change_lib_path_macos.py
fi

# Archive volume
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume.tar volume < /dev/null
    rm -rf volume
fi

if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition $PREFIX/src/environmentComposition
    # detach volume
    hdiutil detach volume
fi

