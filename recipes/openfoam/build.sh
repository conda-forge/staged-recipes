#!/bin/bash

set -x 

echo "Hello!"

# [WM_PROJECT_VERSION] - A human-readable version name
# A development version is often named 'com' - as in www.openfoam.com
export WM_PROJECT_VERSION=v2106

#------------------------------------------------------------------------------
# Configuration environment variables.
# Override with <prefs.sh> instead of editing here.

# [WM_COMPILER_TYPE] - Compiler location:
# = system | ThirdParty
export WM_COMPILER_TYPE=system

# [WM_COMPILER] - Compiler:
# = Gcc | Clang | Icc | Icx | Cray | Amd | Arm | Pgi | Fujitsu |
#   Gcc<digits> | Clang<digits>
export WM_COMPILER=Gcc

# [WM_PRECISION_OPTION] - Floating-point precision:
# = DP | SP | SPDP
export WM_PRECISION_OPTION=DP

# [WM_LABEL_SIZE] - Label size in bits:
# = 32 | 64
export WM_LABEL_SIZE=32

# [WM_COMPILE_OPTION] - Optimised(default), debug, profiling, other:
# = Opt | Debug | Prof
# Other is processor or packaging specific (eg, OptKNL)
export WM_COMPILE_OPTION=Opt

# [WM_COMPILE_CONTROL] - additional control for compiler rules
#   +gold   : with gold linker
#   ~openmp : without openmp
#export WM_COMPILE_CONTROL="+gold"

# [WM_MPLIB] - MPI implementation:
# = SYSTEMOPENMPI | OPENMPI | SYSTEMMPI | MPI | MPICH | MPICH-GM |
#   HPMPI | CRAY-MPICH | FJMPI | QSMPI | SGIMPI | INTELMPI | USERMPI
# Specify SYSTEMOPENMPI1, SYSTEMOPENMPI2 for internal tracking (if desired)
# Can also use INTELMPI-xyz etc and define your own wmake rule
export WM_MPLIB=SYSTEMOPENMPI


#------------------------------------------------------------------------------
# (advanced / legacy)

# [WM_PROJECT] - This project is "OpenFOAM" - do not change
export WM_PROJECT=OpenFOAM

# [projectDir] - directory containing this OpenFOAM version.
# \- When this file is located as $WM_PROJECT_DIR/etc/bashrc, the next lines
#    should work when sourced by BASH or ZSH shells. If this however fails,
#    set one of the fallback values to an appropriate path.
#
#    This can be removed if an absolute path is provided for WM_PROJECT_DIR
#    later on in this file
# --
# projectDir="${BASH_SOURCE:-${ZSH_NAME:+$0}}";
# [ -n "$projectDir" ] && projectDir="$(\cd $(dirname $projectDir)/.. && \pwd -L)" ||\
# projectDir="$HOME/OpenFOAM/OpenFOAM-$WM_PROJECT_VERSION"
# projectDir="/opt/openfoam/OpenFOAM-$WM_PROJECT_VERSION"
# projectDir="/usr/local/OpenFOAM/OpenFOAM-$WM_PROJECT_VERSION"
################################################################################
# Or optionally hard-coded (eg, with autoconfig)
# projectDir="@PROJECT_DIR@"
: # Safety statement (if the user removed all fallback values)

# [FOAM_SIGFPE] - Trap floating-point exceptions.
#               - overrides the 'trapFpe' controlDict entry
# = true | false
#export FOAM_SIGFPE=true

# [FOAM_SETNAN] - Initialize memory with NaN
#               - overrides the 'setNaN' controlDict entry
# = true | false
#export FOAM_SETNAN=false

# [FOAM_ABORT] - Treat exit() on FatalError as abort()
# = true | false
#export FOAM_ABORT=false

# [FOAM_CODE_TEMPLATES] - dynamicCode templates
# - unset: uses 'foamEtcFile -list codeTemplates/dynamicCode'
##export FOAM_CODE_TEMPLATES="$WM_PROJECT_DIR/etc/codeTemplates/dynamicCode"

# [FOAM_JOB_DIR] - location of jobControl
#                - unset: equivalent to ~/.OpenFOAM/jobControl
# export FOAM_JOB_DIR="$HOME/.OpenFOAM/jobControl"

# [WM_OSTYPE] - Operating System Type (set automatically)
# = POSIX | MSwindows
#export WM_OSTYPE=POSIX

# [WM_ARCH_OPTION] - compiling with -m32 option on 64-bit system
# = 32 | 64
#   * on a 64-bit OS this can be 32 or 64
#   * on a 32-bit OS this option is ignored (always 32-bit)
#export WM_ARCH_OPTION=64

# [FOAM_EXTRA_CFLAGS, FOAM_EXTRA_CXXFLAGS, FOAM_EXTRA_LDFLAGS]
# Additional compilation flags - do not inherit from the environment.
# Set after sourcing or via <prefs.sh> to avoid surprises.
unset FOAM_EXTRA_CFLAGS FOAM_EXTRA_CXXFLAGS FOAM_EXTRA_LDFLAGS

echo "Hello!"

################################################################################
# NO (NORMAL) USER EDITING BELOW HERE

# Capture values of old directories to be cleaned from PATH, LD_LIBRARY_PATH
foamOldDirs="$WM_PROJECT_DIR $WM_THIRD_PARTY_DIR \
    $HOME/$WM_PROJECT/$USER $FOAM_USER_APPBIN $FOAM_USER_LIBBIN \
    $WM_PROJECT_SITE $FOAM_SITE_APPBIN $FOAM_SITE_LIBBIN \
    $FOAM_MODULE_APPBIN $FOAM_MODULE_LIBBIN"

echo "Hello!"

# [WM_PROJECT_DIR] - Location of this OpenFOAM version
export WM_PROJECT_DIR=src/OpenFOAM-v2106

echo "Hello!"

# [WM_PROJECT_USER_DIR] - Location of user files
export WM_PROJECT_USER_DIR="$HOME"

# [WM_PROJECT_SITE] - Location of site-specific (group) files
# Default (unset) implies WM_PROJECT_DIR/site
# Normally defined in calling environment

echo "Hello!"


# # Finalize setup of OpenFOAM environment
# if [ -d "$WM_PROJECT_DIR" ]
# then
#     if [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ]
#     then
#         echo "Hello!"
#         echo "source $WM_PROJECT_DIR/etc/config.sh/setup" 1>&2
#         echo "Hello!"
#     fi
#     . "$WM_PROJECT_DIR/etc/config.sh/setup" "$@"
# else
#     echo "Error: did not locate installation path for $WM_PROJECT-$WM_PROJECT_VERSION" 1>&2
#     echo "No directory: $WM_PROJECT_DIR" 1>&2
# fi

# [FOAM_API] - The API level for the project
export FOAM_API=$("$WM_PROJECT_DIR/bin/foamEtcFile" -show-api)

# The installation parent directory
prefixDir="${WM_PROJECT_DIR%/*}"

# Load shell functions
unset WM_SHELL_FUNCTIONS
. "$WM_PROJECT_DIR/etc/config.sh/functions"


# [WM_THIRD_PARTY_DIR] - Location of third-party software components
# \- This may be installed in a directory parallel to the OpenFOAM project
#    directory, with the same version name or using the API value.
#    It may also not be required at all, in which case use a dummy
#    "ThirdParty" inside of the OpenFOAM project directory.
#
# Test out-of-source directories for an "Allwmake" file (source)
# or a "platforms/" directory (runtime-only)

export WM_THIRD_PARTY_DIR=""  # Empty value (before detection)

if [ -e "$WM_PROJECT_DIR/ThirdParty" ]
then
    # Directory or file (masks use of ThirdParty entirely)
    WM_THIRD_PARTY_DIR="$WM_PROJECT_DIR/ThirdParty"
else
    _foamEcho "Locating ThirdParty directory"
    for foundDir in \
        "$prefixDir/ThirdParty-$WM_PROJECT_VERSION" \
        "$prefixDir/ThirdParty-v$FOAM_API" \
        "$prefixDir/ThirdParty-$FOAM_API" \
        "$prefixDir/ThirdParty-common" \
        ;
    do
        _foamEcho "... $foundDir"
        if [ -d "$foundDir" ]
        then
            if [ -f "$foundDir/Allwmake" ] || \
               [ -d "$foundDir/platforms" ]
            then
                WM_THIRD_PARTY_DIR="$foundDir"
                break
            else
                _foamEcho "    does not have Allwmake or platforms/"
            fi
        fi
    done
fi

if [ -z "$WM_THIRD_PARTY_DIR" ]
then
    # Dummy fallback value
    WM_THIRD_PARTY_DIR="$WM_PROJECT_DIR/ThirdParty"
    _foamEcho "Dummy ThirdParty $WM_THIRD_PARTY_DIR"
else
    _foamEcho "ThirdParty $WM_THIRD_PARTY_DIR"
fi
# Done with ThirdParty discovery


# Overrides via <prefs.sh>
# 1. Always use O(ther) values from the OpenFOAM project etc/ directory
_foamEtc -mode=o prefs.sh

# 2. (U)ser or (G)roup values (unless disabled).
unset configMode
if [ -z "$FOAM_CONFIG_MODE" ]
then
    configMode="ug"
else
    case "$FOAM_CONFIG_MODE" in (*[u]*) configMode="${configMode}u" ;; esac
    case "$FOAM_CONFIG_MODE" in (*[g]*) configMode="${configMode}g" ;; esac
fi
if [ -n "$configMode" ]
then
    _foamEtc -mode="$configMode" prefs.sh
fi


#----------------------------------------------------------------------------

# Capture and evaluate command-line parameters
# - set/unset values, specify additional files etc.
# - parameters never start with '-'
if [ "$#" -gt 0 ] && [ "${1#-}" = "${1}" ]
then
    FOAM_SETTINGS="$@"
    if [ -n "$FOAM_SETTINGS" ]
    then
        export FOAM_SETTINGS

        for foamVar_eval
        do
            case "$foamVar_eval" in
            (-*)
                # Stray option (not meant for us here) -> get out
                break
                ;;
            (=*)
                # Junk
                ;;
            (*=)
                # name=       -> unset name
                [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ] \
                    && echo "unset ${foamVar_eval%=}" 1>&2
                eval "unset ${foamVar_eval%=}"
                ;;
            (*=*)
                # name=value  -> export name=value
                [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ] \
                    && echo "export $foamVar_eval" 1>&2
                eval "export $foamVar_eval"
                ;;
            (*)
                # Filename: source it
                if [ -f "$foamVar_eval" ]
                then
                    [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ] \
                        && echo "Using: $foamVar_eval" 1>&2
                    . "$foamVar_eval"
                elif [ -n "$foamVar_eval" ]
                then
                    _foamEtc -silent "$foamVar_eval"
                fi
                ;;
            esac
        done
    else
        unset FOAM_SETTINGS
    fi
else
    unset FOAM_SETTINGS
fi
unset foamVar_eval


#----------------------------------------------------------------------------

# Verify FOAM_CONFIG_ETC (from calling environment or from prefs)
if [ -n "$FOAM_CONFIG_ETC" ]
then
    if [ "$FOAM_CONFIG_ETC" = "etc" ] \
    || [ "$FOAM_CONFIG_ETC" = "$WM_PROJECT_DIR/etc" ]
    then
        # Redundant value
        unset FOAM_CONFIG_ETC
    else
        export FOAM_CONFIG_ETC
    fi
else
    unset FOAM_CONFIG_ETC
fi


# Clean standard environment variables (PATH, MANPATH, LD_LIBRARY_PATH)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
export PATH MANPATH LD_LIBRARY_PATH
_foamClean PATH "$foamOldDirs"
_foamClean MANPATH "$foamOldDirs"
_foamClean LD_LIBRARY_PATH "$foamOldDirs"

# Setup for OpenFOAM compilation etc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_foamEtc -config  settings

# Setup for third-party packages
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_foamEtc -config  mpi
_foamEtc -config  paraview -- "$@"  # Pass through for evaluation
_foamEtc -config  vtk
_foamEtc -config  adios2
_foamEtc -config  CGAL
_foamEtc -config  scotch
_foamEtc -config  FFTW

if [ -d "$WM_PROJECT_DIR/doc/man1" ]
then
    _foamAddMan "$WM_PROJECT_DIR/doc"
fi

# Interactive shell (use PS1, not tty)
if [ -n "$PS1" ]
then
    _foamEtc -config  aliases
    [ "${BASH_VERSINFO:-0}" -ge 4 ] && _foamEtc -config  bash_completion
fi


# Clean environment paths again. Only remove duplicates
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
export PATH MANPATH LD_LIBRARY_PATH

_foamClean PATH
_foamClean MANPATH
_foamClean LD_LIBRARY_PATH

# Add trailing ':' for system manpages
if [ -n "$MANPATH" ]
then
    MANPATH="${MANPATH}:"
fi


# Cleanup temporary information
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "hello!!!!"

# Unload shell functions
# . "$WM_PROJECT_DIR/etc/config.sh/functions"
if [ -z "$WM_SHELL_FUNCTIONS" ]
then
    # Not previously loaded/defined - define now

    # Temporary environment variable to track loading/unloading of functions
    WM_SHELL_FUNCTIONS=loaded

    # Cleaning environment variables
    foamClean="$WM_PROJECT_DIR/bin/foamCleanPath"

    # Cleaning environment variables
    unset -f _foamClean 2>/dev/null
    _foamClean()
    {
         foamVar_name="$1"
         shift
         eval "$($foamClean -sh-env="$foamVar_name" "$@")"
         unset "foamVar_name"
    }

    # Echo values to stderr when FOAM_VERBOSE is on, no-op otherwise
    # Source an etc file, possibly with some verbosity
    # - use eval to avoid intermediate variables (ksh doesn't have 'local')
    unset -f _foamEcho 2>/dev/null
    unset -f _foamEtc 2>/dev/null
    if [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ]
    then
        _foamEcho() { echo "$@" 1>&2; }
        _foamEtc() {
            eval "$("$WM_PROJECT_DIR"/bin/foamEtcFile -sh-verbose "$@")";
        }
    else
        _foamEcho() { true; }
        _foamEtc() {
            eval "$("$WM_PROJECT_DIR"/bin/foamEtcFile -sh "$@")";
        }
    fi

    # Prepend PATH
    unset -f _foamAddPath 2>/dev/null
    _foamAddPath()
    {
        [ -n "$1" ] && export PATH="$1:$PATH"
    }

    # Prepend MANPATH
    unset -f _foamAddMan 2>/dev/null
    _foamAddMan()
    {
        [ -n "$1" ] && export MANPATH="$1:$MANPATH"
    }

    # Prepend LD_LIBRARY_PATH
    unset -f _foamAddLib 2>/dev/null
    _foamAddLib()
    {
        [ -n "$1" ] && export LD_LIBRARY_PATH="$1:$LD_LIBRARY_PATH"
    }

    # Prepend to LD_LIBRARY_PATH with additional checking
    # $1 = base directory for 'lib' or 'lib64'
    # $2 = fallback libname ('lib' or 'lib64')
    #
    # 0) Skip entirely if directory ends in "-none" or "-system".
    #    These special cases (disabled, system directories) should not require
    #    adjustment of LD_LIBRARY_PATH
    # 1) Check for dir/lib64 and dir/lib
    # 2) Use fallback if the previous failed
    #
    # Return 0 on success
    unset -f _foamAddLibAuto 2>/dev/null
    _foamAddLibAuto()
    {
        # Note ksh does not have 'local' thus these ugly variable names
        foamVar_prefix="$1"
        foamVar_end="${1##*-}"

        # Do not add (none) or a system directory
        if [ -z "$foamVar_prefix" ] || [ "$foamVar_end" = none ] || [ "$foamVar_end" = system ]
        then
            unset foamVar_prefix foamVar_end
            return 1
        elif [ -d "$foamVar_prefix" ]
        then
            for foamVar_end in lib$WM_COMPILER_LIB_ARCH lib
            do
                if [ -d "$foamVar_prefix/$foamVar_end" ]
                then
                    export LD_LIBRARY_PATH="$foamVar_prefix/$foamVar_end:$LD_LIBRARY_PATH"
                    unset foamVar_prefix foamVar_end
                    return 0
                fi
            done
        fi

        # Use fallback. Add without checking existence of the directory
        foamVar_end=$2
        if [ -n "$foamVar_end" ]
        then
            case "$foamVar_end" in
            /*)     # An absolute path
                export LD_LIBRARY_PATH="$foamVar_end:$LD_LIBRARY_PATH"
                ;;
            (*)     # Relative to prefix
                export LD_LIBRARY_PATH="$foamVar_prefix/$foamVar_end:$LD_LIBRARY_PATH"
                ;;
            esac
            unset foamVar_prefix foamVar_end
            return 0
        fi

        unset foamVar_prefix foamVar_end
        return 1    # Nothing set
    }


    # Special treatment for Darwin
    # - DYLD_LIBRARY_PATH instead of LD_LIBRARY_PATH
    if [ "$(uname -s 2>/dev/null)" = Darwin ]
    then
        unset -f _foamAddLib _foamAddLibAuto 2>/dev/null

        # Prepend DYLD_LIBRARY_PATH
        _foamAddLib()
        {
            [ -n "$1" ] && export DYLD_LIBRARY_PATH="$1:$DYLD_LIBRARY_PATH"
        }

        # Prepend to DYLD_LIBRARY_PATH with additional checking
        # - use lib-dir script instead of rewriting
        _foamAddLibAuto()
        {
            eval "$("$WM_PROJECT_DIR"/bin/tools/lib-dir -sh "$@")";
        }
    fi


    #--------------------------------------------------------------------------
    # Avoid any ThirdParty settings that may have 'leaked' into the environment

    unset MPI_ARCH_PATH
    unset ADIOS_ARCH_PATH
    unset ADIOS1_ARCH_PATH
    unset ADIOS2_ARCH_PATH
    unset BOOST_ARCH_PATH
    unset CCMIO_ARCH_PATH
    unset CGAL_ARCH_PATH
    unset FFTW_ARCH_PATH
    unset GPERFTOOLS_ARCH_PATH
    unset GMP_ARCH_PATH
    unset MPFR_ARCH_PATH
    unset LLVM_ARCH_PATH
    unset MESA_ARCH_PATH
    unset METIS_ARCH_PATH
    unset SCOTCH_ARCH_PATH

else
    # Was previously loaded/defined - now unset

    unset -f _foamAddPath _foamAddMan _foamAddLib _foamAddLibAuto 2>/dev/null
    unset -f _foamClean _foamEcho _foamEtc 2>/dev/null
    unset foamClean
    unset WM_SHELL_FUNCTIONS

fi



# Variables (done as the last statement for a clean exit code)
unset cleaned foamOldDirs foundDir prefixDir



echo "Hello!"

# Cleanup variables (done as final statement for a clean exit code)
unset foamOldDirs projectDir

echo "Hello!"

cd src/OpenFOAM-v2106

echo "Hello!"

ls

echo "Hello!"

# foamSystemCheck

# foam

# ./Allwmake -s -l
