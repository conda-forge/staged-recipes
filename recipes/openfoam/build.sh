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
projectDir="${BASH_SOURCE:-${ZSH_NAME:+$0}}";
[ -n "$projectDir" ] && projectDir="$(\cd $(dirname $projectDir)/.. && \pwd -L)" ||\
projectDir="$HOME/OpenFOAM/OpenFOAM-$WM_PROJECT_VERSION"
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

# [WM_PROJECT_DIR] - Location of this OpenFOAM version
export WM_PROJECT_DIR=src/OpenFOAM-v2106

# [WM_PROJECT_USER_DIR] - Location of user files
export WM_PROJECT_USER_DIR="$HOME/$WM_PROJECT/$USER-$WM_PROJECT_VERSION"

# [WM_PROJECT_SITE] - Location of site-specific (group) files
# Default (unset) implies WM_PROJECT_DIR/site
# Normally defined in calling environment

echo "Hello!"


# Finalize setup of OpenFOAM environment
if [ -d "$WM_PROJECT_DIR" ]
then
    if [ -n "$FOAM_VERBOSE" ] && [ -n "$PS1" ]
    then
        echo "source $WM_PROJECT_DIR/etc/config.sh/setup" 1>&2
    fi
    . "$WM_PROJECT_DIR/etc/config.sh/setup" "$@"
else
    echo "Error: did not locate installation path for $WM_PROJECT-$WM_PROJECT_VERSION" 1>&2
    echo "No directory: $WM_PROJECT_DIR" 1>&2
fi

echo "Hello!"

# Cleanup variables (done as final statement for a clean exit code)
unset foamOldDirs projectDir

cd src/OpenFOAM-v2106

echo "Hello!"

ls

# foamSystemCheck

# foam

# ./Allwmake -s -l
