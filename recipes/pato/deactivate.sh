#!/usr/bin/env bash
LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume"
if [ -d $LOCALMOUNTPOINT ]; then
    if mount | grep "on $LOCALMOUNTPOINT" > /dev/null; then
	source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/config.sh/unset
	unset PATO_DIR
        unset LIB_PATO
        unset PATO_UNIT_TESTING
        unset PATO_TUTORIALS
        unset MPP_DIRECTORY
        unset MPP_DATA_DIRECTORY
        unalias pato
        unalias solo
        unalias utio
        unalias libo
        unalias tuto
        unalias 1D
        unalias 1
        unalias 2D
        unalias 3D
        unalias muto
        hdiutil detach $LOCALMOUNTPOINT
	rm -rf $CONDA_PREFIX/src/volume
    fi
fi
