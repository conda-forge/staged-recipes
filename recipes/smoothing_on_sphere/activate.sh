# Installed only on Windows, for conda environments activated from Bash.
_smoothing_saved_prefix_key="_SMOOTHING_LIBOMP_PREFIX_${CONDA_SHLVL}"
if [ "${LIBOMP_PREFIX+x}" = x ]; then
    export "${_smoothing_saved_prefix_key}=${LIBOMP_PREFIX}"
else
    unset "${_smoothing_saved_prefix_key}"
fi
export LIBOMP_PREFIX="${CONDA_PREFIX}/Library"
unset _smoothing_saved_prefix_key
