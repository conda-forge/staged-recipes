
function despyfits_backup_and_make_envvar() {
    local way=$1
    local envvar=$2

    if [[ ${way} == "activate" ]]; then
        local appval=$3
        eval oldval="\$${envvar}"

        eval "export DESPYFITS_BACKUP_${envvar}=\"${oldval}\""
        eval "export ${envvar}=\"${appval}\""
    else
        eval backval="\$DESPYFITS_BACKUP_${envvar}"

        if [[ ! ${backval} ]]; then
            eval "unset ${envvar}"
        else
            eval "export ${envvar}=\"${backval}\""
        fi
        eval "unset DESPYFITS_BACKUP_${envvar}"
    fi
}

export -f despyfits_backup_and_make_envvar

despyfits_backup_and_make_envvar activate DESPYFITS_DIR ${CONDA_PREFIX}/despyfits
