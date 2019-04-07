#!/usr/bin/env bash
set -exu

package_name=$1
var=$2
data_dir=$3

warning_message="WARNING: ${var} has been changed from \$${var} to \$CONDA_PREFIX/${data_dir}"

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

# Bash activation
echo 'if [ ! -z "$'${var}'" ]; then
    echo "'${warning_message}'"
fi

export '${var}'=${CONDA_PREFIX}/'${data_dir}'
' >> "${PREFIX}/etc/conda/activate.d/activate-${package_name}.sh"
# Bash deactivation
echo 'unset '${var} >> "${PREFIX}/etc/conda/deactivate.d/deactivate-${package_name}.sh"

# csh activation
echo 'if ( $?'${var}') then
    echo "'${warning_message}'"
endif

setenv '${var}' "${CONDA_PREFIX}/'${data_dir}'"
' >> "${PREFIX}/etc/conda/activate.d/activate-${package_name}.csh"
# csh deactivation
echo 'unsetenv '${var} >> "${PREFIX}/etc/conda/deactivate.d/deactivate-${package_name}.csh"

# fish activation
echo 'test ! -n "$'${var}'"; or echo "'${warning_message}'"

set -gx '${var}' "$CONDA_PREFIX/'${data_dir}'"
' >> "${PREFIX}/etc/conda/activate.d/activate-${package_name}.fish"
# fish deactivation
echo 'set -e '${var} >> "${PREFIX}/etc/conda/deactivate.d/deactivate-${package_name}.fish"

# Windows activation (replacing / with \ in data_dir)
echo '@if not defined CONDA_PREFIX goto:eof

@set "'${var}'=%CONDA_PREFIX%\'${data_dir//\//\\}'"
' >> "${PREFIX}/etc/conda/activate.d/activate-${package_name}.bat"
# Windows deactivation
echo '@set "'${var}'="' >> "${PREFIX}/etc/conda/deactivate.d/deactivate-${package_name}.bat"
