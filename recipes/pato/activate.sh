#!/usr/bin/env bash
echo activate OpenFOAM and PATO
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ]; then
	mkdir -p $CONDA_PREFIX/src/volume
    fi
    hdiutil attach -mountpoint $CONDA_PREFIX/src/volume $CONDA_PREFIX/src/pato_releases_conda.sparsebundle
fi
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ]; then
	tar xvf $CONDA_PREFIX/src/volume.tar -C $CONDA_PREFIX/src > /dev/null
	rm -f $CONDA_PREFIX/src/volume.tar
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
fi
if [ -f $CONDA_PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7/etc/bashrc ]; then
    CURRENT_DIR=$PWD
    cd $CONDA_PREFIX/src/volume
    echo "source $CONDA_PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7/etc/bashrc > /dev/null 2>&1" > .foam-extend_WM_OPTIONS.sh
    echo "echo \$WM_OPTIONS" >> .foam-extend_WM_OPTIONS.sh
    chmod +x .foam-extend_WM_OPTIONS.sh
    export FOAM_EXTEND_WM_OPTIONS=$(./.foam-extend_WM_OPTIONS.sh)
    rm -f .foam-extend_WM_OPTIONS.sh
    cd $CURRENT_DIR
    export FOAM_EXTEND_SRC=$CONDA_PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7/src
    export FOAM_EXTEND_LIB=$CONDA_PREFIX/src/volume/foam-extend/foam-extend-4.1_for_openfoam-7/lib/$FOAM_EXTEND_WM_OPTIONS
    unset FOAM_EXTEND_WM_OPTIONS
fi
if [ -f $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc ]; then
    if [ "$(uname)" = "Linux" ]; then
	alias wmRefresh=""
    fi
    source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
fi
if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1/bashrc ]; then
    export PATO_DIR=$CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1
    source $PATO_DIR/bashrc
fi
if [ "$(uname)" = "Darwin" ]; then
    if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition ]; then
	if [ -f $CONDA_PREFIX/src/environmentComposition ]; then
	    cp $CONDA_PREFIX/src/environmentComposition $CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
	    rm -f $CONDA_PREFIX/src/environmentComposition
	fi
    fi
fi
