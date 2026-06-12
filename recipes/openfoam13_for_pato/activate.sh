#!/usr/bin/env bash
echo activate openfoam13_for_pato
curr_dir=$PWD

# --- macOS: mount sparse bundle ---
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_openfoam13_for_pato" ]; then
        mkdir -p "$CONDA_PREFIX/src/volume_openfoam13_for_pato"
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_openfoam13_for_pato " > /dev/null; then
            cd "$i/src"
            hdiutil detach volume_openfoam13_for_pato
            cd "$curr_dir"
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_openfoam13_for_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
        hdiutil attach -mountpoint "$CONDA_PREFIX/src/volume_openfoam13_for_pato" "$CONDA_PREFIX/src/openfoam13_for_pato_conda.sparsebundle"
    fi
fi

# --- Linux: extract archive and create compiler symlinks ---
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_openfoam13_for_pato" ]; then
        tar xvf "$CONDA_PREFIX/src/volume_openfoam13_for_pato.tar" -C "$CONDA_PREFIX/src" > /dev/null
        rm -f "$CONDA_PREFIX/src/volume_openfoam13_for_pato.tar"
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

# --- macOS: one-time post-install setup (libPstream fix + codesigning) ---
if [ "$(uname)" = "Darwin" ]; then
    OF13_PLATFORMS="$CONDA_PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/platforms"
    SIGN_MARKER="$CONDA_PREFIX/src/volume_openfoam13_for_pato/.codesigned"

    if [ ! -f "$SIGN_MARKER" ] && [ -d "$OF13_PLATFORMS" ]; then
        echo "openfoam13_for_pato: one-time post-install setup..."

        # Fix libPstream: copy dummy lib for serial mode (OF13 puts MPI libPstream in openmpi-system/).
        for plat_dir in "$OF13_PLATFORMS"/darwin64*; do
            LIBDIR="$plat_dir/lib"
            if [ -f "$LIBDIR/dummy/libPstream.dylib" ] && [ ! -f "$LIBDIR/libPstream.dylib" ]; then
                cp "$LIBDIR/dummy/libPstream.dylib" "$LIBDIR/libPstream.dylib"
            fi
            # Fix @rpath/libc++.1.dylib reference in MPI Pstream so it resolves without DYLD_LIBRARY_PATH.
            if [ -f "$LIBDIR/openmpi-system/libPstream.dylib" ]; then
                install_name_tool -change "@rpath/libc++.1.dylib" "/usr/lib/libc++.1.dylib" \
                    "$LIBDIR/openmpi-system/libPstream.dylib" 2>/dev/null || true
            fi
        done

        # Re-sign all binaries: conda package assembly invalidates the build-time signatures.
        # On Darwin 25+ (macOS 16+), binaries compiled on older macOS may fail strict Mach-O
        # validation, causing codesign to silently succeed but the binary to remain unexecutable.
        # We verify against a representative binary before committing to the full signing pass.
        _test_bin=""
        for plat_dir in "$OF13_PLATFORMS"/darwin64*; do
            for candidate in "$plat_dir/bin/foamRun" "$plat_dir/bin/blockMesh"; do
                if [ -f "$candidate" ]; then
                    _test_bin="$candidate"
                    break 2
                fi
            done
        done

        _sign_ok=false
        if [ -n "$_test_bin" ]; then
            /usr/bin/codesign --force -s - "$_test_bin" 2>/dev/null
            if /usr/bin/codesign --verify "$_test_bin" 2>/dev/null; then
                _sign_ok=true
            fi
        else
            # No test binary found — assume signing will work and proceed.
            _sign_ok=true
        fi

        if [ "$_sign_ok" = "true" ]; then
            echo "openfoam13_for_pato: re-signing binaries (this may take a moment)..."
            find "$OF13_PLATFORMS" -type f \( -name "*.dylib" -o -perm -111 \) | while read -r f; do
                /usr/bin/codesign --force -s - "$f" 2>/dev/null || true
            done
            touch "$SIGN_MARKER"
            echo "openfoam13_for_pato: post-install setup complete."
        else
            _darwin_major=$(uname -r | cut -d. -f1)
            _macos_ver=$((_darwin_major - 9))
            echo ""
            echo "WARNING: openfoam13_for_pato: could not re-sign OpenFOAM 13 binaries."
            echo "  Kernel: $(uname -r) — Darwin ${_darwin_major} (macOS ${_macos_ver})"
            if [ "${_darwin_major}" -ge 25 ] 2>/dev/null; then
                echo "  Darwin 25+ enforces stricter Mach-O validation. Binaries compiled on"
                echo "  older macOS versions cannot be re-signed on this system."
                echo "  Fix: rebuild the openfoam13_for_pato package natively on Darwin ${_darwin_major}."
            else
                echo "  Unexpected signing failure. Check that /usr/bin/codesign is functional."
            fi
            echo "  OpenFOAM 13 commands will not work until this is resolved."
            echo "  This setup will be retried on the next conda activation."
            echo ""
            unset _test_bin _sign_ok _darwin_major _macos_ver
            return 0 2>/dev/null || true
        fi

        unset _test_bin _sign_ok _darwin_major _macos_ver
    fi
fi

# --- Source OpenFOAM 13 environment ---
if [ -f "$CONDA_PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/etc/bashrc" ]; then
    alias wmRefresh=""
    source "$CONDA_PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/etc/bashrc"
fi

# --- Fix DYLD_LIBRARY_PATH space corruption from _foamAddLib ---
# OF13's _foamAddLib appends paths with a space separator instead of ':',
# breaking DYLD_LIBRARY_PATH. Normalise to colon-separated, deduplicated list.
_fix_dyld_path() {
    local input="$1"
    local fixed
    fixed=$(echo "$input" | sed 's| /|:/|g')
    echo "$fixed" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//'
}
if [ -n "$DYLD_LIBRARY_PATH" ]; then
    export DYLD_LIBRARY_PATH=$(_fix_dyld_path "$DYLD_LIBRARY_PATH")
fi
if [ -n "$FOAM_DYLD_LIBRARY_PATH" ]; then
    export FOAM_DYLD_LIBRARY_PATH=$(_fix_dyld_path "$FOAM_DYLD_LIBRARY_PATH")
fi
unset -f _fix_dyld_path
