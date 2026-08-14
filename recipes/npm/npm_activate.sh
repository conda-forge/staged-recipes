if [ -z "${_CONDA_NPM_PATH_BACKUP+x}" ]; then
    export _CONDA_NPM_PATH_BACKUP="${PATH}"
    export PATH="${CONDA_PREFIX}/libexec/npm/bin:${PATH}"
fi
