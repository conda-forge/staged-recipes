#!/bin/sh
# Restore CALCHEP to its pre-activation value (see activate.sh).
if [ -n "${CALCHEP_CONDA_BACKUP:-}" ]; then
    CALCHEP="${CALCHEP_CONDA_BACKUP}"
    export CALCHEP
    unset CALCHEP_CONDA_BACKUP
else
    unset CALCHEP
fi
