conda_cacert_scan_backup_and_append_envvar() {
    _way="$1"
    _envvar="$2"

    if [ "${_way}" = "activate" ]; then
        _appval="$3"
        _appsep="$4"
        eval _oldval="\$${_envvar}"

        eval "export CONDA_CACERT_SCAN_BACKUP_${_envvar}=\"${_oldval}\""
        if [ -z "${_oldval}" ]; then
            eval "export ${_envvar}=\"${_appval}\""
        else
            eval "export ${_envvar}=\"${_oldval}${_appsep}${_appval}\""
        fi
    else
        eval _backval="\$CONDA_CACERT_SCAN_BACKUP_${_envvar}"

        if [ -z "${_backval}" ]; then
            eval "unset ${_envvar}"
        else
            eval "export ${_envvar}=\"${_backval}\""
        fi
        eval "unset CONDA_CACERT_SCAN_BACKUP_${_envvar}"
    fi
}

conda_cacert_scan_backup_and_append_envvar deactivate CACERT_SCAN_ROOTS
conda_cacert_scan_backup_and_append_envvar deactivate CACERT_SCAN_WATCH
