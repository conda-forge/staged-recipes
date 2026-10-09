#!/bin/sh
# Point acados_template at the conda environment so it can locate the acados
# libraries, headers and the t_renderer binary.  Save any pre-existing value so
# it can be restored on deactivation.
export _CONDA_BACKUP_ACADOS_SOURCE_DIR="${ACADOS_SOURCE_DIR:-}"
export ACADOS_SOURCE_DIR="${CONDA_PREFIX}"
