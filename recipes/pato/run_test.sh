#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
cd $PREFIX/src
if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $PREFIX/src/environmentComposition $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
    rm -f $PREFIX/src/environmentComposition
fi
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $PREFIX/src/volume ]; then
        tar xvf $PREFIX/src/volume.tar -C $PREFIX/src > /dev/null
    fi
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
    if [ -f $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc ]; then
        alias wmRefresh=""
	source $PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
    fi
    if [ -f $PREFIX/src/volume/PATO/PATO-dev-2.3.1/bashrc ]; then
	export PATO_DIR=$PREFIX/src/volume/PATO/PATO-dev-2.3.1
	source $PATO_DIR/bashrc
    fi
fi
# run tests
which runtests
runtests

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
