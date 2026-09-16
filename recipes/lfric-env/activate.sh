#!/bin/sh
# lfric-env -- THE STAGE-1 ACTIVATION CONTRACT.
#
# Installed as $PREFIX/etc/conda/activate.d/zzz-lfric-env.sh, so `conda activate`
# sources it. This is the conda analogue of the `lfric-env` Lmod modulefile in the
# Spack delivery (ickc/lfric-env-isambard, scripts/lfric-env.lua): the one place
# that says what "the LFRic environment is active" means.
#
# Only variables that LFRic's build system requires to be spelled a PARTICULAR WAY
# are here. Anything `conda activate` already does correctly (PATH, the compiler
# activation, library search paths, PYTHONPATH) is left alone.
#
# NOT here, deliberately: APPS_ROOT_DIR / CORE_ROOT_DIR / PHYSICS_ROOT. The Spack
# modulefile points those at its own vendored LFRic checkout, but LFRic SOURCE is
# Stage 2, not Stage 1 -- a suite owns its extract tree and sets them itself. A
# package guessing a path there would be wrong for every real workflow.
#
# FILENAME PREFIX -- `zzz-` is load-bearing. conda sources activate.d/*.sh in
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
# environment's own headers and libraries win over a caller's, matching the
# modulefile's pushenv.
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

# --- 1. Compilers, spelled the way LFRic dispatches on ----------------------
# LFRic picks its compiler flag file by the LEAF NAME of $FC / $CXX
# (lfric_core/infrastructure/build/fortran/<fc>.mk, cxx/<cxx>.mk). It ships
# mpif90.mk and mpic++.mk -- so conda's <arch>-conda-linux-gnu-gfortran (no .mk)
# and mpich's mpicxx alias (no mpicxx.mk) both fail. This is the single most
# load-bearing pair in the file, and the Spack modulefile sets exactly the same
# one for its from-source variant.
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
# LFRic itself is a linux activity; macOS support here is for the library stack.
if [ -z "${MPICH_CXX:-}" ]; then
    if [ -n "${_lfric_gxx}" ]; then
        MPICH_CXX="${_lfric_gxx}"
        export MPICH_CXX
    elif [ -n "${CONDA_TOOLCHAIN_HOST:-}" ] &&
         [ -x "${CONDA_PREFIX}/bin/${CONDA_TOOLCHAIN_HOST}-g++" ]; then
        MPICH_CXX="${CONDA_PREFIX}/bin/${CONDA_TOOLCHAIN_HOST}-g++"
        export MPICH_CXX
    fi
fi
unset _lfric_gxx

# LFRic preprocesses Fortran with a traditional-mode cpp.
if [ -z "${FPP:-}" ]; then
    FPP="cpp -traditional-cpp"
    export FPP
fi

# Which flag-file set to build with. meto-spice is the generic GNU/Linux one and
# is what the Spack modulefile defaults to as well. A suite that knows better sets
# its own before activating, and that value is kept.
if [ -z "${LFRIC_TARGET_PLATFORM:-}" ]; then
    LFRIC_TARGET_PLATFORM=meto-spice
    export LFRIC_TARGET_PLATFORM
fi

# --- 2. Where the environment's headers and libraries are -------------------
# `mpif90` already injects $CONDA_PREFIX/{include,lib}, but LFRic's Makefiles read
# FFLAGS/LDFLAGS directly -- that is how the XIOS/yaxt/netCDF .mod files and their
# archives are found -- so spell them out.
_lfric_env_prepend FFLAGS "-I${CONDA_PREFIX}/include"
# Prepended in reverse, so the result reads "-L... -Wl,-rpath,... <caller's>".
_lfric_env_prepend LDFLAGS "-Wl,-rpath,${CONDA_PREFIX}/lib"
_lfric_env_prepend LDFLAGS "-L${CONDA_PREFIX}/lib"

# lfric_apps links -lshum from $SHUMLIB_ROOT/{include,lib}. conda merges every
# package into one prefix, so that root is the environment itself.
SHUMLIB_ROOT="${CONDA_PREFIX}"
export SHUMLIB_ROOT

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
# way for a script (or a person) to check that Stage 1 is active, and which
# environment it is.
LFRIC_ENV_ACTIVE="${CONDA_PREFIX}"
export LFRIC_ENV_ACTIVE

unset -f _lfric_env_save _lfric_env_prepend
