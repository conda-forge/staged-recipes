#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING OPENFOAM 13 ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# Create soft links for the compilers
if [ "$(uname)" = "Linux" ]; then
    current_dir=$PWD
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
    cd $current_dir
fi

# Create soft link for mac OS tools (gsed only; install_name_tool not needed for pre-compiled)
if [ "$(uname)" = "Darwin" ]; then
    cp $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# create volume_openfoam13_for_pato folder
if [ ! -d $PREFIX/src/volume_openfoam13_for_pato ]; then
    mkdir -p $PREFIX/src/volume_openfoam13_for_pato
fi
cd $PREFIX/src

if [ "$(uname)" = "Linux" ]; then
    # move src to volume_openfoam13_for_pato
    mv $SRC_DIR/src/Linux/* $PREFIX/src/volume_openfoam13_for_pato/
    rm -rf $SRC_DIR/src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume: openfoam13_for_pato_conda.sparsebundle
    # 4g is sufficient for pre-compiled binaries (no compilation needed)
    hdiutil create -size 4g -type SPARSEBUNDLE -fs HFSX -volname openfoam13_for_pato_conda -fsargs -s openfoam13_for_pato_conda.sparsebundle
    # attach volume_openfoam13_for_pato
    hdiutil attach -mountpoint volume_openfoam13_for_pato openfoam13_for_pato_conda.sparsebundle
    # move src to volume_openfoam13_for_pato
    mv $SRC_DIR/src/MacOS/* $PREFIX/src/volume_openfoam13_for_pato/
    rm -rf $SRC_DIR/src
fi

# get OpenFOAM 13 src
cd $PREFIX/src/volume_openfoam13_for_pato/OpenFOAM
tar xvf OpenFOAM-13.tar
tar xvf ThirdParty-13.tar

if [ "$(uname)" = "Darwin" ]; then
    PLAT_LIB="$PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13/platforms/darwin64ClangDPInt32Opt/lib"

    # Fix case-mismatched dylib filenames on HFSX (case-sensitive) volume.
    # If the tarball was staged on case-insensitive APFS, liblagrangian.dylib and
    # libLagrangian.dylib may have collapsed into one (losing the capital-L library).
    # Create lowercase symlinks so dyld can find libs by their install-name.
    if [ -f "$PLAT_LIB/libLagrangian.dylib" ] && [ ! -f "$PLAT_LIB/liblagrangian.dylib" ]; then
        ln -sf libLagrangian.dylib "$PLAT_LIB/liblagrangian.dylib"
    fi
    if [ -f "$PLAT_LIB/libLagrangianFunctionObjects.dylib" ] && [ ! -f "$PLAT_LIB/liblagrangianFunctionObjects.dylib" ]; then
        ln -sf libLagrangianFunctionObjects.dylib "$PLAT_LIB/liblagrangianFunctionObjects.dylib"
    fi

    # Symlink dummy serial stubs into lib/ so DYLD_LIBRARY_PATH can find them.
    # Binaries like decomposePar reference lib/dummy/libmetisDecomp.dylib as an
    # absolute path pointing to the developer's volume_openfoam13 (not _for_pato).
    # Adding symlinks in lib/ lets DYLD_LIBRARY_PATH intercept the lookup first.
    for stub in libmetisDecomp.dylib libscotchDecomp.dylib libptscotchDecomp.dylib libMGridGen.dylib; do
        if [ -f "$PLAT_LIB/dummy/$stub" ] && [ ! -f "$PLAT_LIB/$stub" ] && [ ! -L "$PLAT_LIB/$stub" ]; then
            ln -sf "dummy/$stub" "$PLAT_LIB/$stub"
        fi
    done
fi

if [ "$(uname)" = "Linux" ]; then
    # Patch scotch/ptscotch configs to use conda-provided libs ($PREFIX) instead of
    # Homebrew or ThirdParty. The source tree may contain mac-specific overrides that
    # call 'brew --prefix scotch', which is wrong in a conda build environment.
    cat > OpenFOAM-13/etc/config.sh/scotch << 'SCOTCHEOF'
export SCOTCH_VERSION=conda
export SCOTCH_ARCH_PATH=$PREFIX
SCOTCHEOF

    # Also patch the mac-specific override if present (uses _foamGetPackageArchPath → brew)
    if [ -f OpenFOAM-13/etc/config.sh/mac/scotch ]; then
        cat > OpenFOAM-13/etc/config.sh/mac/scotch << 'MACSCOTCHEOF'
export SCOTCH_VERSION=conda
export SCOTCH_ARCH_PATH=$PREFIX
MACSCOTCHEOF
    fi

    # Patch ptscotch Make/options: remove hardcoded brew/CONDA_PREFIX references
    cat > OpenFOAM-13/src/parallel/decompose/ptscotch/Make/options << 'PTEOF'
-include $(GENERAL_RULES)/mplibType

EXE_INC = \
    $(PFLAGS) $(PINC) \
    -I$(FOAM_SRC)/Pstream/mpi/lnInclude \
    -I$(SCOTCH_ARCH_PATH)/include/$(FOAM_MPI) \
    -I$(SCOTCH_ARCH_PATH)/include \
    -I../decompositionMethods/lnInclude

ifeq ($(SO),dylib)
LIB_LIBS = \
    -Wl,-needed_library,$(SCOTCH_ARCH_PATH)/lib/libptscotch.dylib \
    -Wl,-needed_library,$(SCOTCH_ARCH_PATH)/lib/libptscotcherrexit.dylib \
    -Wl,-needed_library,$(SCOTCH_ARCH_PATH)/lib/libscotch.dylib
else
LIB_LIBS = \
    -L$(SCOTCH_ARCH_PATH)/lib \
    $(if $(PTSCOTCH_LIB_DIR),-L$(PTSCOTCH_LIB_DIR)) \
    -L$(FOAM_EXT_LIBBIN)/$(FOAM_MPI) \
    -lptscotch \
    -lptscotcherrexit \
    -lscotch \
    -lrt
endif
PTEOF

    # compile OpenFOAM-13
    export WM_NCOMPPROCS=`nproc` # parallel build
    cd $PREFIX/src/volume_openfoam13_for_pato/OpenFOAM/OpenFOAM-13
    alias wmRefresh=""
    source etc/bashrc
    ./Allwmake -j
fi

# macOS: no compilation. The pre-compiled tarball (prepared by prepare_prebuilt_macos.sh)
# already contains compiled binaries and bundled scotch/ptscotch/mpi dylibs.
# The scotch config was already patched to use $CONDA_PREFIX in the tarball.
# All rpath resolution is handled at runtime via DYLD_LIBRARY_PATH (set by OF13 bashrc).

# Archive volume_openfoam13_for_pato
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume_openfoam13_for_pato.tar volume_openfoam13_for_pato > /dev/null
    rm -rf volume_openfoam13_for_pato
fi

if [ "$(uname)" = "Darwin" ]; then
    # cd out of the volume before detaching (macOS refuses to unmount if CWD is inside)
    cd /tmp
    hdiutil detach "$PREFIX/src/volume_openfoam13_for_pato"

    # Expand sparse band files to their full 8 MB size BEFORE conda-build packages them.
    # APFS stores sparsebundle bands as sparse files; conda-build records their sparse
    # (logical) size in paths.json. On user machines the same data expands to the full
    # 8 MB band size during extraction, causing a conda SafetyError size mismatch.
    # truncate -s 8388608 is a no-op if the file is already that size, extends with
    # zeros otherwise. No stat needed — avoids BSD vs GNU stat syntax differences.
    find "$PREFIX/src/openfoam13_for_pato_conda.sparsebundle/bands" -type f \
        -exec truncate -s 8388608 {} \;
fi
