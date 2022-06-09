
function pixcorrect_backup_and_make_envvar() {
    local way=$1
    local envvar=$2

    if [[ ${way} == "activate" ]]; then
        local appval=$3
        eval oldval="\$${envvar}"

        eval "export PIXCORRECT_BACKUP_${envvar}=\"${oldval}\""
        eval "export ${envvar}=\"${appval}\""
    else
        eval backval="\$PIXCORRECT_BACKUP_${envvar}"

        if [[ ! ${backval} ]]; then
            eval "unset ${envvar}"
        else
            eval "export ${envvar}=\"${backval}\""
        fi
        eval "unset PIXCORRECT_BACKUP_${envvar}"
    fi
}

export -f pixcorrect_backup_and_make_envvar

pixcorrect_backup_and_make_envvar activate PIXCORRECT_DIR ${CONDA_PREFIX}/pixcorrect
