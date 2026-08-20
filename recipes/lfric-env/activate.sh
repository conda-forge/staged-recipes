#!/bin/sh
# lfric-env -- THE ACTIVATION CONTRACT.
#
# Installed as $PREFIX/etc/conda/activate.d/zzz-lfric-env.sh, so `conda activate`
# sources it. This is the one place that says what "the LFRic environment is
# active" means, and is the conda analogue of the module file HPC sites load.
#
# Only variables that LFRic's build system requires to be spelled a PARTICULAR WAY
# are here. Anything `conda activate` already does correctly (PATH, the compiler
# activation, library search paths, PYTHONPATH) is left alone.
#
# NOT here, deliberately: APPS_ROOT_DIR / CORE_ROOT_DIR / PHYSICS_ROOT. Those point
# at a checkout of the model source, which is the user's, not this package's -- a
# workflow owns its extract tree and sets them itself, and a package guessing a
# path there would be wrong for every real workflow.
#
# FILENAME PREFIX -- the `zzz-` matters. conda sources activate.d/*.sh in
# sorted order, and conda-forge's compiler activation scripts are named
# `activate-<pkg>_<subdir>.sh`. This must run AFTER them, because it overrides the
# CXX they set and reads the GXX they export. (The matching deactivate script is
# prefixed `000-` for the mirror-image reason -- see deactivate.sh.)

# --- save/restore bookkeeping ----------------------------------------------
# Every variable touched below is saved first, so the deactivate script can put
# the shell back exactly as it found it -- including "was unset" as distinct from
# "was empty", which is why there is a separate _LFRIC_ENV_HAD_<var> marker rather
# than just an empty saved value. POSIX sh: no arrays, no ${!var}, hence eval.
#
# The save is IDEMPOTENT: if a marker already exists this is a re-activation (a
# nested `conda activate`, a Cylc task shell sourcing the environment again), and
# the ORIGINAL pre-lfric-env value must be kept. Saving again would record our own
# `mpic++` as the value to restore, and `conda deactivate` would then leave the
# shell holding lfric-env's settings for ever.
_lfric_env_save() {
    eval "if [ -n \"\${_LFRIC_ENV_HAD_$1+x}\" ]; then
              :
          elif [ -n \"\${$1+x}\" ]; then
              _LFRIC_ENV_HAD_$1=1; _LFRIC_ENV_SAVED_$1=\"\$$1\"
              export _LFRIC_ENV_HAD_$1 _LFRIC_ENV_SAVED_$1
          else
              _LFRIC_ENV_HAD_$1=0; export _LFRIC_ENV_HAD_$1
          fi"
}

# Prepend a flag to a space-separated variable, but only if it is not already
# there, so re-activation (a Cylc task shell, a nested `conda activate`) does not
# accumulate duplicates. Prepending -- not appending -- is what makes this
# environment's own headers and libraries win over a caller's.
_lfric_env_prepend() {
    _lfric_var="$1"
    _lfric_flag="$2"
    eval "_lfric_cur=\"\${$_lfric_var:-}\""
    case " ${_lfric_cur} " in
        *" ${_lfric_flag} "*) ;;
        *)
            if [ -n "${_lfric_cur}" ]; then
                _lfric_new="${_lfric_flag} ${_lfric_cur}"
            else
                _lfric_new="${_lfric_flag}"
            fi
            eval "${_lfric_var}=\"\${_lfric_new}\"; export ${_lfric_var}"
            ;;
    esac
    unset _lfric_var _lfric_flag _lfric_cur _lfric_new
}

for _lfric_v in FC LDMPI CXX MPICH_CXX FPP LFRIC_TARGET_PLATFORM \
                FFLAGS LDFLAGS SHUMLIB_ROOT HDF5_USE_FILE_LOCKING \
                PYTHONDONTWRITEBYTECODE LFRIC_ENV_ACTIVE; do
    _lfric_env_save "$_lfric_v"
done
unset _lfric_v

# --- 0. Which prefix is this? -----------------------------------------------
# `conda activate` exports CONDA_PREFIX and that is the normal answer. A package
# BUILD/TEST environment is the exception: conda-build and rattler-build activate
# the prefix but describe it as $PREFIX, so the recipe's own test would otherwise
# see every path below come out empty.
#
# $PREFIX alone is NOT a safe fallback -- it is one of the most commonly set
# variables there is (`make install PREFIX=/usr/local` and friends), and pointing
# SHUMLIB_ROOT or -L at /usr/local would be silently wrong. Require it to look
# like a conda prefix, which is what conda-meta/ means.
_lfric_prefix="${CONDA_PREFIX:-}"
if [ -z "${_lfric_prefix}" ] && [ -n "${PREFIX:-}" ] && [ -d "${PREFIX}/conda-meta" ]; then
    _lfric_prefix="${PREFIX}"
fi

# --- 1. Compilers, spelled the way LFRic dispatches on ----------------------
# LFRic picks its compiler flag file by the LEAF NAME of $FC / $CXX
# (lfric_core/infrastructure/build/fortran/<fc>.mk, cxx/<cxx>.mk). It ships
# mpif90.mk and mpic++.mk -- so conda's <arch>-conda-linux-gnu-gfortran (no .mk)
# and mpich's mpicxx alias (no mpicxx.mk) both fail. This is the single most
# important pair in the file, and is the same pair HPC module files set.
#
# GXX is read BEFORE CXX is overridden: it is conda's g++-named driver, exported
# by the compiler activation that ran ahead of this script.
_lfric_gxx="${GXX:-}"

FC=mpif90
LDMPI=mpif90
CXX=mpic++
export FC LDMPI CXX

# lfric_core's cxx/mpic++.mk identifies the C++ backend from the FIRST WORD of
# `mpic++ --version` and requires it to contain "g++". conda's mpic++ wraps the
# "c++"-named driver (<arch>-conda-linux-gnu-c++), which echoes that program name
# -- no "g++" in it. Point the wrapper at the identically-configured g++-named
# driver instead (same gcc, so ABI-safe). gfortran needs no equivalent because it
# always prints "GNU Fortran".
#
# Set only when a g++ driver actually exists, which is a GNU-toolchain (linux)
# property: on macOS conda-forge's C/C++ compiler is clang and there is no g++, so
# this is silently skipped rather than warned about on every activation. Building
# the model itself is a linux activity; macOS support here is for the library
# stack (development and testing on a laptop).
if [ -z "${MPICH_CXX:-}" ]; then
    if [ -n "${_lfric_gxx}" ]; then
        # Note GXX is conventionally a BARE COMMAND NAME
        # (x86_64-conda-linux-gnu-g++), not a path. That is fine and is what
        # mpich wants: it resolves MPICH_CXX through PATH.
        MPICH_CXX="${_lfric_gxx}"
        export MPICH_CXX
    elif [ -n "${CONDA_TOOLCHAIN_HOST:-}" ] &&
         [ -n "${_lfric_prefix}" ] &&
         [ -x "${_lfric_prefix}/bin/${CONDA_TOOLCHAIN_HOST}-g++" ]; then
        MPICH_CXX="${_lfric_prefix}/bin/${CONDA_TOOLCHAIN_HOST}-g++"
        export MPICH_CXX
    elif [ -n "${_lfric_prefix}" ]; then
        # Neither variable is available. Both come from the compiler activation
        # script, and there is no guarantee it has run: conda sources
        # activate.d/ in sorted order (hence this file's `zzz-` prefix), but a
        # package TEST prefix activates differently and may not run it at all --
        # which is exactly where this was first seen to be unset.
        #
        # The driver itself does not depend on any of that: gxx_<subdir>
        # installs it as a real file in the prefix, so find it directly. The
        # glob simply fails to match on macOS, where the C++ compiler is clang
        # and there is no g++ to point at -- which is the correct outcome there.
        for _lfric_gpp in "${_lfric_prefix}"/bin/*-g++; do
            if [ -x "${_lfric_gpp}" ]; then
                MPICH_CXX="${_lfric_gpp}"
                export MPICH_CXX
                break
            fi
        done
        unset _lfric_gpp
    fi
fi
unset _lfric_gxx

# LFRic preprocesses Fortran with a traditional-mode cpp.
if [ -z "${FPP:-}" ]; then
    FPP="cpp -traditional-cpp"
    export FPP
fi

# Which flag-file set to build with. meto-spice is LFRic's generic GNU/Linux one,
# and is the usual default elsewhere too. A workflow that knows better sets its
# own before activating, and that value is kept.
if [ -z "${LFRIC_TARGET_PLATFORM:-}" ]; then
    LFRIC_TARGET_PLATFORM=meto-spice
    export LFRIC_TARGET_PLATFORM
fi

# --- 2. Where the environment's headers and libraries are -------------------
# `mpif90` already injects $CONDA_PREFIX/{include,lib}, but LFRic's Makefiles read
# FFLAGS/LDFLAGS directly -- that is how the XIOS/yaxt/netCDF .mod files and their
# archives are found -- so spell them out.
# Guarded on the prefix having been resolved at all: with no usable prefix these
# would expand to bare "-I/include" and a SHUMLIB_ROOT of "", which is worse than
# leaving them alone. The compiler settings above stay useful either way.
if [ -n "${_lfric_prefix}" ]; then
    _lfric_env_prepend FFLAGS "-I${_lfric_prefix}/include"
    # Prepended in reverse, so the result reads "-L... -Wl,-rpath,... <caller's>".
    _lfric_env_prepend LDFLAGS "-Wl,-rpath,${_lfric_prefix}/lib"
    _lfric_env_prepend LDFLAGS "-L${_lfric_prefix}/lib"

    # lfric_apps links -lshum from $SHUMLIB_ROOT/{include,lib}. conda merges every
    # package into one prefix, so that root is the environment itself.
    SHUMLIB_ROOT="${_lfric_prefix}"
    export SHUMLIB_ROOT
fi

# --- 3. Runtime -------------------------------------------------------------
# HDF5 1.10+ flock()s the files it creates; Lustre (and some CI filesystems)
# reject that, so XIOS's nc_create() of a NetCDF-4 output aborts with "Permission
# denied" after leaving a 0-byte file -- the model integrates fine, it just cannot
# write diagnostics. Disabling HDF5's own locking is the standard remedy and is
# safe here (Cylc serialises task access to these paths). Any value already set
# by the caller wins.
if [ -z "${HDF5_USE_FILE_LOCKING:-}" ]; then
    HDF5_USE_FILE_LOCKING=FALSE
    export HDF5_USE_FILE_LOCKING
fi

# PSyclone and the LFRic build otherwise scatter .pyc files through the source
# tree they are handed, which is usually a read-only or per-task extract.
PYTHONDONTWRITEBYTECODE=1
export PYTHONDONTWRITEBYTECODE

# Informational marker: which prefix this contract was last applied for. A cheap
# way for a script (or a person) to check that the environment is active, and
# which one it is.
LFRIC_ENV_ACTIVE="${_lfric_prefix}"
export LFRIC_ENV_ACTIVE

unset _lfric_prefix
unset -f _lfric_env_save _lfric_env_prepend
