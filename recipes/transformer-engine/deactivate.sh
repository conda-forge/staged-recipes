if [[ -n "${CUDA_HOME_BACKUP:-}" ]]
then
    export CUDA_HOME="${CUDA_HOME_BACKUP}"
    unset CUDA_HOME_BACKUP
fi
