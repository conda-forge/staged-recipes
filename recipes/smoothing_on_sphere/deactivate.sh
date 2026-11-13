_smoothing_saved_prefix_key="_SMOOTHING_LIBOMP_PREFIX_${CONDA_SHLVL}"
if [ "${!_smoothing_saved_prefix_key+x}" = x ]; then
    export LIBOMP_PREFIX="${!_smoothing_saved_prefix_key}"
    unset "${_smoothing_saved_prefix_key}"
else
    unset LIBOMP_PREFIX
fi
unset _smoothing_saved_prefix_key
