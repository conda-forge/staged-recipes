#!/usr/bin/env bash
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ]; then
	mkdir -p $CONDA_PREFIX/src/volume
    fi
    hdiutil attach -mountpoint $CONDA_PREFIX/src/volume $CONDA_PREFIX/src/pato_releases_conda.sparsebundle
fi
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ]; then
	tar xvf $CONDA_PREFIX/src/volume.tar -C $CONDA_PREFIX/src
    fi
fi
if [ -f $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc ]; then
    source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
fi
if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1/bashrc ]; then
    export PATO_DIR=$CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1
    source $PATO_DIR/bashrc
fi
