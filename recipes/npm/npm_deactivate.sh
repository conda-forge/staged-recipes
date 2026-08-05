if [ -n "${_CONDA_NPM_PATH_BACKUP+x}" ]; then
    export PATH="${_CONDA_NPM_PATH_BACKUP}"
    unset _CONDA_NPM_PATH_BACKUP
fi
