if [[ ! -z "${CUDA_HOME_BACKUP+x}" ]]
then
    export CUDA_HOME="${CUDA_HOME_BACKUP}"
    unset CUDA_HOME_BACKUP
fi
