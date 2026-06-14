#!/usr/bin/env bash
echo "activate pato-of13"

curr_dir=$PWD

# --- macOS: create and mount sparse bundle ---
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_pato" ]; then
        mkdir -p "$CONDA_PREFIX/src/volume_pato"
    fi
    if [ ! -d "$CONDA_PREFIX/src/volume_pato.sparsebundle" ]; then
        cd "$CONDA_PREFIX/src"
        hdiutil create -size 32g -type SPARSEBUNDLE -fs HFSX -volname volume_pato -fsargs -s volume_pato.sparsebundle
        cd "$curr_dir"
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_pato " > /dev/null; then
            cd "$i/src"
            hdiutil detach volume_pato
            cd "$curr_dir"
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
        hdiutil attach -mountpoint "$CONDA_PREFIX/src/volume_pato" "$CONDA_PREFIX/src/volume_pato.sparsebundle"
    fi
fi

# --- Linux: create volume_pato directory and compiler symlinks ---
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_pato" ]; then
        mkdir -p "$CONDA_PREFIX/src/volume_pato"
    fi
    dir_gcc=$(dirname "$(which x86_64-conda-linux-gnu-gcc 2>/dev/null)" 2>/dev/null)
    if [ -n "$dir_gcc" ]; then
        cd "$dir_gcc"
        files=$(find . -name "x86_64-conda-linux-gnu-*" -type f)
        for x in $files
        do
            old_name="${x#"./"}"
            new_name="${x#"./x86_64-conda-linux-gnu-"}"
            if [ ! -f "$new_name" ]; then
                ln -s "$old_name" "$new_name"
            fi
        done
        cd "$curr_dir"
    fi
fi

# --- Clone PATO if not present ---
if [ ! -d "$CONDA_PREFIX/src/volume_pato/PATO-dev" ]; then
    cd "$CONDA_PREFIX/src/volume_pato"
    echo "Cloning PATO-dev (openfoam13 branch)..."
    git clone -b openfoam13 git@gitlab.com:PATO/PATO-dev.git
    if [ ! -d "$CONDA_PREFIX/src/volume_pato/PATO-dev" ]; then
        echo 1>&2 "Error: Could not clone PATO-dev. Make sure you have SSH access to gitlab.com/PATO/PATO-dev."
        cd "$curr_dir"
        return 1 2>/dev/null || exit 1
    fi
    cd "$curr_dir"
fi

# --- Build PATO if not yet built (mutation++ install is the sentinel) ---
if [ ! -d "$CONDA_PREFIX/src/volume_pato/PATO-dev/src/thirdParty/mutation++/install" ]; then
    export PATO_DIR="$CONDA_PREFIX/src/volume_pato/PATO-dev"
    # Ensure wmake is available — openfoam13_for_pato must have sourced OF13's bashrc first.
    # If hdiutil failed for OF13, wmake won't be in PATH; try an explicit fallback source.
    if ! command -v wmake >/dev/null 2>&1; then
        _of13_bashrc="$CONDA_PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/etc/bashrc"
        if [ -f "$_of13_bashrc" ]; then
            alias wmRefresh=""
            source "$_of13_bashrc"
        fi
        unset _of13_bashrc
    fi
    if ! command -v wmake >/dev/null 2>&1; then
        echo "" >&2
        echo "ERROR: pato-of13: wmake not found. openfoam13_for_pato must be mounted and activated." >&2
        echo "  Check for hdiutil errors above. If another env has the OpenFOAM 13 volume" >&2
        echo "  mounted, deactivate it first, then re-activate this environment." >&2
        echo "" >&2
        cd "$curr_dir"
        return 1 2>/dev/null || exit 1
    fi
    source "$PATO_DIR/bashrc"
    echo "Building PATO (this may take a few minutes)..."
    "$PATO_DIR/Allwmake"
    cd "$curr_dir"
fi

# --- Source PATO on subsequent activations ---
if [ -f "$CONDA_PREFIX/src/volume_pato/PATO-dev/bashrc" ]; then
    export PATO_DIR="$CONDA_PREFIX/src/volume_pato/PATO-dev"
    source "$PATO_DIR/bashrc"
fi

# --- macOS: codesign binaries if needed ---
if [ "$(uname)" = "Darwin" ]; then
    for dir_i in "$CONDA_PREFIX" "$PREFIX"
    do
        if [ -f "$dir_i/src/volume_pato/PATO-dev/install/bin/runtests" ]; then
            output=$("$dir_i/src/volume_pato/PATO-dev/install/bin/runtests" -h 2>&1)
            output_len=${#output}
            if [ ! "$output_len" -gt 0 ]; then
                echo "Codesigning OpenFOAM 13 and PATO binaries..."
                of_dir="$dir_i/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/platforms/darwin64ClangDPInt32Opt"
                mu_dir="$dir_i/src/volume_pato/PATO-dev/src/thirdParty/mutation++/install"
                pa_dir="$dir_i/src/volume_pato/PATO-dev/install"
                for d in "$mu_dir/lib" "$mu_dir/bin" "$pa_dir/lib" "$pa_dir/bin"; do
                    [ -d "$d" ] || continue
                    find "$d" -type f \( -name "*.dylib" -o -perm -111 \) | while read -r f; do
                        /usr/bin/codesign --remove-signature "$f" 2>/dev/null || true
                        /usr/bin/codesign --force -s - "$f" 2>/dev/null || true
                    done
                done
            fi
        fi
    done
fi
