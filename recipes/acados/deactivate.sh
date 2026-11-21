#!/bin/sh
# Restore ACADOS_SOURCE_DIR to whatever it was before this environment was
# activated (unset it if it was previously empty/undefined).
export ACADOS_SOURCE_DIR="${_CONDA_BACKUP_ACADOS_SOURCE_DIR:-}"
unset _CONDA_BACKUP_ACADOS_SOURCE_DIR
if [ -z "${ACADOS_SOURCE_DIR}" ]; then
  unset ACADOS_SOURCE_DIR
fi
