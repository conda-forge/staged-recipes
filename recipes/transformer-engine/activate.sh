if [[ ! -z "${CUDA_HOME +x}" ]]
then
    export CUDA_HOME_BACKUP="${CUDA_HOME}"
fi
export CUDA_HOME="${CONDA_PREFIX}"
