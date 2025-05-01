if [[ -n "${CUDA_HOME:-}" ]]
then
    export CUDA_HOME_BACKUP="${CUDA_HOME}"
fi
export CUDA_HOME="${CONDA_PREFIX}"
