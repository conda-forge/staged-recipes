#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING OPENFOAM 13 ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# Create soft links for the compilers
if [ "$(uname)" = "Linux" ]; then
    current_dir=$PWD
    dir_gcc=$(dirname `which x86_64-conda-linux-gnu-gcc`)
    cd $dir_gcc
    files=`find . -name "x86_64-conda-linux-gnu-*" -type f`
    for x in $files
    do
    old_name=${x#"./"}
    new_name=${x#"./x86_64-conda-linux-gnu-"}
    if [ ! -f $new_name ]; then
            ln -s $old_name $new_name
    fi
    done
    cd $current_dir
fi

# Create soft link for mac OS tools
if [ "$(uname)" = "Darwin" ]; then
    ln -s arm64-apple-darwin20.0.0-install_name_tool install_name_tool
fi

# create volume_openfoam13_for_pato folder
if [ ! -d $PREFIX/src/volume_openfoam13_for_pato ]; then
    mkdir -p $PREFIX/src/volume_openfoam13_for_pato
fi
cd $PREFIX/src

if [ "$(uname)" = "Linux" ]; then
    # move src to volume_openfoam13_for_pato
    mv $SRC_DIR/src/Linux/* $PREFIX/src/volume_openfoam13_for_pato/
    rm -rf $SRC_DIR/src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume: openfoam13_for_pato_conda.sparsebundle
    hdiutil create -size 32g -type SPARSEBUNDLE -fs HFSX -volname openfoam13_for_pato_conda -fsargs -s openfoam13_for_pato_conda.sparsebundle
    # attach volume_openfoam13_for_pato
    hdiutil attach -mountpoint volume_openfoam13_for_pato openfoam13_for_pato_conda.sparsebundle
    # move src to volume_openfoam13_for_pato
    mv $SRC_DIR/src/MacOS/* $PREFIX/src/volume_openfoam13_for_pato/
    rm -rf $SRC_DIR/src
    mv $SRC_DIR/change_lib_path_macos.py $PREFIX/src/
    cp $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# get OpenFOAM 13 src
cd $PREFIX/src/volume_openfoam13_for_pato/OpenFOAM
tar xvf OpenFOAM-13.tar
tar xvf ThirdParty-13.tar

# compile OpenFOAM-13
if [ "$(uname)" = "Linux" ]; then
    export WM_NCOMPPROCS=`nproc` # parallel build
fi
if [ "$(uname)" = "Darwin" ]; then
    export WM_NCOMPPROCS=`sysctl -n hw.ncpu` # parallel build
fi
cd $PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13
alias wmRefresh=""
source etc/bashrc
./Allwmake -j

# Change the libraries paths to $PREFIX
cd $PREFIX/src
export SRC_DIR=$PWD
if [ "$(uname)" = "Darwin" ]; then
    python change_lib_path_macos.py
    rm -f change_lib_path_macos.py
fi

# Archive volume_openfoam13_for_pato
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume_openfoam13_for_pato.tar volume_openfoam13_for_pato > /dev/null
    rm -rf volume_openfoam13_for_pato
fi

if [ "$(uname)" = "Darwin" ]; then
    # detach volume_openfoam13_for_pato
    hdiutil detach volume_openfoam13_for_pato
fi
