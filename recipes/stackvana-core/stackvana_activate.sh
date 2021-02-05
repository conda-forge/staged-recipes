# note that before calling this script, you must check that eups has not already
# been activated. for example, the conda activate script for stackvana-core is
#
#     if [[ ! ${STACKVANA_ACTIVATED} ]]; then
#         source ${CONDA_PREFIX}/lsst_home/stackvana_activate.sh
#     fi
#

# a flag to indicate stackvana is activated
export STACKVANA_ACTIVATED=1

# clean/backup any EUPS stuff
export STACKVANA_BACKUP_EUPS_PKGROOT=${EUPS_PKGROOT}
export EUPS_PKGROOT="https://eups.lsst.codes/stack/src"

# backup the python path since eups will muck with it
export STACKVANA_BACKUP_PYTHONPATH=${PYTHONPATH}

# backup the LD paths since the DM stack will muck with them
export STACKVANA_BACKUP_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
export STACKVANA_BACKUP_DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
export STACKVANA_BACKUP_LSST_LIBRARY_PATH=${LSST_LIBRARY_PATH}

# instruct sconsUtils to use the conda compilers
export STACKVANA_BACKUP_SCONSUTILS_USE_CONDA_COMPILERS=${SCONSUTILS_USE_CONDA_COMPILERS}
export SCONSUTILS_USE_CONDA_COMPILERS=1

# finally setup env so we can build packages
function stackvana_backup_and_append_envvar() {
    local way=$1
    local envvar=$2

    if [[ ${way} == "activate" ]]; then
        local appval=$3
        local appsep=$4
        eval oldval="\$${envvar}"

        eval "export STACKVANA_BACKUP_${envvar}=\"${oldval}\""
        if [[ ! ${oldval} ]]; then
            eval "export ${envvar}=\"${appval}\""
        else
            eval "export ${envvar}=\"${oldval}${appsep}${appval}\""
        fi
    else
        eval backval="\$STACKVANA_BACKUP_${envvar}"

        if [[ ! ${backval} ]]; then
            eval "unset ${envvar}"
        else
            eval "export ${envvar}=\"${backval}\""
        fi
        eval "unset STACKVANA_BACKUP_${envvar}"
    fi
}

export -f stackvana_backup_and_append_envvar
