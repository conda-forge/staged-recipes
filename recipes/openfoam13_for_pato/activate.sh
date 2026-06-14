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
        if ! hdiutil attach -mountpoint "$LOCALMOUNTPOINT" "$CONDA_PREFIX/src/openfoam13_for_pato_conda.sparsebundle" 2>/tmp/_of13_hdi_err.txt; then
            # Attach failed — likely the same sparse bundle is already mounted by another conda env
            # (conda hardlinks package files, so envs share the same band files and macOS only
            # allows one mount at a time). Auto-detach from the other env and remount here.
            # Scan ALL active mounts (not just envs/) to find wherever our bundle
            # is currently mounted — this catches stale conda-bld build environments too.
            _bundle_inode=$(ls -id "$CONDA_PREFIX/src/openfoam13_for_pato_conda.sparsebundle/token" 2>/dev/null | awk '{print $1}')
            _remounted=false
            if [ -n "$_bundle_inode" ]; then
                while IFS= read -r _mount_line; do
                    _mount_point=$(echo "$_mount_line" | sed 's/.* on \(.*\) (.*/\1/')
                    [[ "$_mount_point" != */volume_openfoam13_for_pato ]] && continue
                    [ "$_mount_point" = "$LOCALMOUNTPOINT" ] && continue
                    _other_prefix="${_mount_point%/src/volume_openfoam13_for_pato}"
                    _other_bundle="$_other_prefix/src/openfoam13_for_pato_conda.sparsebundle"
                    [ ! -d "$_other_bundle" ] && continue
                    _other_inode=$(ls -id "$_other_bundle/token" 2>/dev/null | awk '{print $1}')
                    if [ "$_bundle_inode" = "$_other_inode" ]; then
                        echo "openfoam13_for_pato: remounting from $_other_prefix → $(basename "$CONDA_PREFIX")"
                        hdiutil detach "$_mount_point" -force 2>/dev/null || true
                        if hdiutil attach -mountpoint "$LOCALMOUNTPOINT" "$CONDA_PREFIX/src/openfoam13_for_pato_conda.sparsebundle" 2>/dev/null; then
                            _remounted=true
                        fi
                        break
                    fi
                done < <(mount)
            fi
            rm -f /tmp/_of13_hdi_err.txt
            unset _bundle_inode _mount_line _mount_point _other_prefix _other_bundle _other_inode
            if [ "$_remounted" = "false" ]; then
                echo "" >&2
                echo "ERROR: openfoam13_for_pato: failed to mount OpenFOAM 13 volume." >&2
                echo "  Run: conda deactivate && conda activate $(basename "$CONDA_PREFIX")" >&2
                echo "" >&2
                unset _remounted
                return 0 2>/dev/null || true
            fi
            unset _remounted
        else
            rm -f /tmp/_of13_hdi_err.txt
        fi
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

# --- macOS: one-time codesigning on first activation per environment ---
# Signatures written during conda build are rejected at runtime on macOS 26+.
# Signing here (in the real user environment) produces valid signatures.
# The SIGN_MARKER lives outside the sparse bundle so each env signs independently.
# Only one env can have the bundle mounted at a time (macOS enforces this),
# so there is no risk of concurrent writes to the shared band files.
if [ "$(uname)" = "Darwin" ]; then
    OF13_PLATFORMS="$CONDA_PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/platforms"
    SIGN_MARKER="$CONDA_PREFIX/src/.openfoam13_for_pato_codesigned"
    if [ ! -f "$SIGN_MARKER" ] && [ -d "$OF13_PLATFORMS" ]; then
        echo "openfoam13_for_pato: signing binaries (once per environment)..."
        find "$OF13_PLATFORMS" -type f \( -name "*.dylib" -o -perm -111 \) | while read -r f; do
            # Strip any existing (possibly corrupted) signature before re-signing.
            # install_name_tool invalidates signatures; --force alone cannot overwrite
            # a malformed signature blob on macOS 26+.
            /usr/bin/codesign --remove-signature "$f" 2>/dev/null || true
            /usr/bin/codesign --force -s - "$f" 2>/dev/null || true
        done
        touch "$SIGN_MARKER"
        echo "openfoam13_for_pato: signing complete."
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
