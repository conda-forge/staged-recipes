export _CONDA_RESTORE_PATH=${PATH}
export _CONDA_RESTORE_MINTPY_HOME=${MINTPY_HOME}

PYTHON_SITE_PACKAGES=$(python -c "import os; from sysconfig import get_paths; print(os.path.relpath(get_paths()['purelib'], '${CONDA_PREFIX}'))")

export MINTPY_HOME=${CONDA_PREFIX}/${PYTHON_SITE_PACKAGES}/mintpy
export PATH=${PATH}:${MINTPY_HOME}
