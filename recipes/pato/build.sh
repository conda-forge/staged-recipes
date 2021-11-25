#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING PATO ###\n"
if [ "$(uname)" = "Darwin" ]; then
    # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
    # This will allow them to be run on environment activation.
    for CHANGE in "activate" "deactivate"
    do
	mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
	cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done
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
    python change_lib_path.py
    # detach volume
    hdiutil detach volume
    # create src/volume and copy pato_releases_conda.sparsebundle
    if [ ! -d $PREFIX/src/volume ]; then
        mkdir -p $PREFIX/src/volume
    fi
    scp -r pato_releases_conda.sparsebundle $PREFIX/src/pato_releases_conda.sparsebundle
    # create pato-env
    echo "echo hdiutil attach -mountpoint \\\$CONDA_PREFIX/src/volume \\\$CONDA_PREFIX/src/pato_releases_conda.sparsebundle\;" > $PREFIX/src/pato-env
    echo "echo source \\\$CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc\;" >> $PREFIX/src/pato-env
    echo "echo export PATO_DIR=\\\$CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1\;" >> $PREFIX/src/pato-env
    echo "echo source \\\$PATO_DIR/bashrc" >> $PREFIX/src/pato-env
    chmod +x $PREFIX/src/pato-env
    # create pato-unset
    echo "echo source \\\$CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset\;" > $PREFIX/src/pato-unset
    echo "echo unset PATO_DIR\;" >> $PREFIX/src/pato-unset
    echo "echo unset LIB_PATO\;" >> $PREFIX/src/pato-unset
    echo "echo unset PATO_UNIT_TESTING\;" >> $PREFIX/src/pato-unset
    echo "echo unset PATO_TUTORIALS\;" >> $PREFIX/src/pato-unset
    echo "echo unset MPP_DIRECTORY\;" >> $PREFIX/src/pato-unset
    echo "echo unset MPP_DATA_DIRECTORY\;" >> $PREFIX/src/pato-unset
    echo "echo unalias pato\;" >> $PREFIX/src/pato-unset
    echo "echo unalias solo\;" >> $PREFIX/src/pato-unset
    echo "echo unalias utio\;" >> $PREFIX/src/pato-unset
    echo "echo unalias libo\;" >> $PREFIX/src/pato-unset
    echo "echo unalias tuto\;" >> $PREFIX/src/pato-unset
    echo "echo unalias 1D\;" >> $PREFIX/src/pato-unset
    echo "echo unalias 1\;" >> $PREFIX/src/pato-unset
    echo "echo unalias 2D\;" >> $PREFIX/src/pato-unset
    echo "echo unalias 3D\;" >> $PREFIX/src/pato-unset
    echo "echo unalias muto\;" >> $PREFIX/src/pato-unset
    echo "echo hdiutil detach \\\$CONDA_PREFIX/src/volume" >> $PREFIX/src/pato-unset
    chmod +x $PREFIX/src/pato-unset
fi
