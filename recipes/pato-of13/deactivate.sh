#!/usr/bin/env bash
echo "deactivate pato-of13"

if [ "$(uname)" = "Darwin" ]; then
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if [ -d "$LOCALMOUNTPOINT" ]; then
        if mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
            if [ -f "$CONDA_PREFIX/src/volume_pato/PATO-dev/bashrc" ] && [ -n "${PATO_DIR}" ]; then
                unset PATO_DIR
                unset LIB_PATO
                unset PATO_UNIT_TESTING
                unset PATO_TUTORIALS
                unset MPP_DIRECTORY
                unset MPP_DATA_DIRECTORY
                unalias pato 2>/dev/null || true
                unalias solo 2>/dev/null || true
                unalias utio 2>/dev/null || true
                unalias libo 2>/dev/null || true
                unalias tuto 2>/dev/null || true
                unalias 1D   2>/dev/null || true
                unalias 1    2>/dev/null || true
                unalias 2D   2>/dev/null || true
                unalias 3D   2>/dev/null || true
                unalias muto 2>/dev/null || true
                for old_path in \
                    "$CONDA_PREFIX/src/volume_pato/PATO-dev/src/thirdParty/mutation++/install/lib" \
                    "$CONDA_PREFIX/src/volume_pato/PATO-dev/install/lib"
                do
                    if [[ "$DYLD_LIBRARY_PATH" == *"${old_path}:"* ]]; then
                        DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH/${old_path}:/}"
                    else
                        DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH/${old_path}/}"
                    fi
                done
                export DYLD_LIBRARY_PATH
            fi
            cd "$CONDA_PREFIX" || true
            hdiutil detach "$LOCALMOUNTPOINT" 2>/dev/null || true
        fi
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ -f "$CONDA_PREFIX/src/volume_pato/PATO-dev/bashrc" ] && [ -n "${PATO_DIR}" ]; then
        unset PATO_DIR
        unset LIB_PATO
        unset PATO_UNIT_TESTING
        unset PATO_TUTORIALS
        unset MPP_DIRECTORY
        unset MPP_DATA_DIRECTORY
        unalias pato 2>/dev/null || true
        unalias solo 2>/dev/null || true
        unalias utio 2>/dev/null || true
        unalias libo 2>/dev/null || true
        unalias tuto 2>/dev/null || true
        unalias 1D   2>/dev/null || true
        unalias 1    2>/dev/null || true
        unalias 2D   2>/dev/null || true
        unalias 3D   2>/dev/null || true
        unalias muto 2>/dev/null || true
        for old_path in \
            "$CONDA_PREFIX/src/volume_pato/PATO-dev/src/thirdParty/mutation++/install/lib" \
            "$CONDA_PREFIX/src/volume_pato/PATO-dev/install/lib"
        do
            if [[ "$LD_LIBRARY_PATH" == *"${old_path}:"* ]]; then
                LD_LIBRARY_PATH="${LD_LIBRARY_PATH/${old_path}:/}"
            else
                LD_LIBRARY_PATH="${LD_LIBRARY_PATH/${old_path}/}"
            fi
        done
        export LD_LIBRARY_PATH
    fi
fi
