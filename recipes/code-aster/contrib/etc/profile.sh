# AUTOMATICALLY GENERATED - DO NOT EDIT !
# Put all your changes in profile_local.sh in the same directory
#
# profile.sh : initialize the environment for as_run services
# (sh, ksh, bash syntax)
#
# If variables are depending on Code_Aster version, use ENV_SH in
# the corresponding 'config.txt' file.
#

if [ -z "${ASTER_ROOT}" ]; then
    [ -z "${BASH_SOURCE[0]}" ] && here="$0" || here="${BASH_SOURCE[0]}"
    ASTER_ROOT=`dirname $(dirname $(dirname $(readlink -f ${here})))`
    export ASTER_ROOT
fi

if [ -z "${ASTER_ETC}" ]; then
    ASTER_ETC="${ASTER_ROOT}"/etc
    if [ "${ASTER_ROOT}" = "/usr" ]; then
        ASTER_ETC=/etc
    fi
    export ASTER_ETC
fi

if [ -z "${PATH}" ]; then
    export PATH="$ASTER_ROOT"/bin:"${ASTER_ROOT}"/outils
else
    export PATH="${ASTER_ROOT}"/bin:"${ASTER_ROOT}"/outils:"${PATH}"
fi

if [ -z "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH="?HOME_PYTHON?"/lib
else
    export LD_LIBRARY_PATH="?HOME_PYTHON?"/lib:"${LD_LIBRARY_PATH}"
fi

if [ -z "${PYTHONPATH}" ]; then
    export PYTHONPATH="?ASRUN_SITE_PKG?"
else
    export PYTHONPATH="?ASRUN_SITE_PKG?":"${PYTHONPATH}"
fi

export PYTHONEXECUTABLE="${PYTHON}"

# this may be required if PYTHONHOME is defined to another location
if [ ! -z "${PYTHONHOME}" ]; then
    export PYTHONHOME="?HOME_PYTHON?"
fi

export WISHEXECUTABLE="?WISH_EXE?"

# define the default temporary directory
# Use profile_local.sh if you need change it!
if [ -z "${ASTER_TMPDIR}" ]; then
    export ASTER_TMPDIR=/tmp
fi

# source local profile
if [ -e "${ASTER_ETC}"/codeaster/profile_local.sh ]; then
    . "${ASTER_ETC}"/codeaster/profile_local.sh
fi
