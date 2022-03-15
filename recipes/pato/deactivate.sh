#!/usr/bin/env bash
echo deactivate OpenFOAM and PATO
if [ "$(uname)" = "Darwin" ]; then
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume"
    if [ -d $LOCALMOUNTPOINT ]; then
	if mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	    if [ -f $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
		source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset
	    fi
	    if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev_2.3.1/bashrc ] && [ ! -z "${PATO_DIR}" ]; then
		unset PATO_DIR
		unset LIB_PATO
		unset PATO_UNIT_TESTING
		unset PATO_TUTORIALS
		unset MPP_DIRECTORY
		unset MPP_DATA_DIRECTORY
		unalias pato 2>/dev/null
		unalias solo 2>/dev/null
		unalias utio 2>/dev/null
		unalias libo 2>/dev/null
		unalias tuto 2>/dev/null
		unalias 1D 2>/dev/null
		unalias 1 2>/dev/null
		unalias 2D 2>/dev/null
		unalias 3D 2>/dev/null
		unalias muto 2>/dev/null
            fi
	    cd $CONDA_PREFIX
	    hdiutil detach $LOCALMOUNTPOINT
	fi
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ -f $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
	source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset
    fi
    if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev_2.3.1/bashrc ] && [ ! -z "${PATO_DIR}" ]; then
	unset PATO_DIR
	unset LIB_PATO
	unset PATO_UNIT_TESTING
	unset PATO_TUTORIALS
	unset MPP_DIRECTORY
	unset MPP_DATA_DIRECTORY
	unalias pato 2>/dev/null
	unalias solo 2>/dev/null
	unalias utio 2>/dev/null
	unalias libo 2>/dev/null
	unalias tuto 2>/dev/null
	unalias 1D 2>/dev/null
	unalias 1 2>/dev/null
	unalias 2D 2>/dev/null
	unalias 3D 2>/dev/null
	unalias muto 2>/dev/null
    fi
fi
