#!/bin/bash
set -e
echo "Testing openfoam13_for_pato..."

if [ "$(uname)" = "Darwin" ]; then
    # Check that the sparsebundle is present
    test -f "$CONDA_PREFIX/src/openfoam13_for_pato_conda.sparsebundle/Info.plist"
    echo "Sparsebundle present: OK"

    # Verify that the sparsebundle is mounted (activate.sh should have done this).
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_openfoam13_for_pato"
    if mount | grep "on $LOCALMOUNTPOINT " > /dev/null 2>&1; then
        echo "Sparsebundle mounted: OK"
        OF13_PLATFORMS="$LOCALMOUNTPOINT/OpenFOAM/OpenFOAM-13/platforms/darwin64ClangDPInt32Opt"

        # Verify key dylibs are non-empty (catches the zero-fill corruption from install_name_tool)
        echo "Checking dylib sizes..."
        _ok=true
        for lib in libfiniteVolume.dylib libmeshTools.dylib libOpenFOAM.dylib; do
            libpath="$OF13_PLATFORMS/lib/$lib"
            if [ ! -f "$libpath" ]; then
                echo "MISSING: $libpath" >&2
                _ok=false
            else
                size=$(wc -c < "$libpath")
                if [ "$size" -lt 100000 ]; then
                    echo "CORRUPT (size=$size): $libpath" >&2
                    _ok=false
                else
                    echo "  $lib: ${size} bytes OK"
                fi
            fi
        done
        if [ "$_ok" = "false" ]; then
            echo "ERROR: One or more dylibs are corrupt/missing." >&2
            exit 1
        fi

        # On macOS 26+, ad-hoc codesigning only produces valid runtime signatures when
        # done from a real user environment.  If signatures are stale, sign now for testing.
        SIGN_MARKER="$CONDA_PREFIX/src/.openfoam13_for_pato_codesigned"
        if [ ! -f "$SIGN_MARKER" ] && [ -d "$OF13_PLATFORMS" ]; then
            echo "Codesigning binaries for test..."
            find "$OF13_PLATFORMS" -type f \( -name "*.dylib" -o -perm -111 \) | while read -r f; do
                /usr/bin/codesign --force -s - "$f" 2>/dev/null || true
            done
            touch "$SIGN_MARKER"
        fi

        # Re-set DYLD_LIBRARY_PATH explicitly: /bin/bash (Apple SIP-hardened) strips
        # inherited DYLD_LIBRARY_PATH at startup, so we must rebuild it here from
        # known paths rather than relying on the activate.sh-set value.
        OF13_LIB="$OF13_PLATFORMS/lib"
        export DYLD_LIBRARY_PATH="$OF13_LIB:$OF13_LIB/openmpi-system${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
        export PATH="$OF13_PLATFORMS/bin:$PATH"

        # Run a quick binary smoke test
        echo "Running binary smoke test..."
        blockMesh -help > /dev/null && echo "blockMesh: OK"
        decomposePar -help > /dev/null && echo "decomposePar: OK"
    else
        # Sparsebundle could not be mounted (e.g., conda-build placeholder-prefix env).
        # Accept this case — the real test happens on first user activation.
        echo "Sparsebundle not mounted (conda-build env or mount conflict); skipping binary tests."
        echo "Dylib integrity will be verified on first user activation."
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    blockMesh -help > /dev/null && echo "blockMesh: OK"
    decomposePar -help > /dev/null && echo "decomposePar: OK"
fi

echo "OpenFOAM 13 for PATO: OK"
