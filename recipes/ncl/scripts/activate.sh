#!/bin/bash
for variable in $(env | grep '^NCARG_');  do
    var_name=$(echo "$variable" | cut -d= -f1)
    var_value="$(echo -n "$variable" | cut -d= -f2-)"
    export OLD_${var_name}="${var_value}"
    unset ${var_name}
done

if [ ! -z "${CONDA_ENV_PATH}" ]; then
    export NCARG_ROOT="$(cd ${CONDA_ENV_PATH} && pwd)"
elif [ ! -z "${CONDA_PREFIX}" ]; then
    export NCARG_ROOT="$(cd ${CONDA_PREFIX} && pwd)"
fi
