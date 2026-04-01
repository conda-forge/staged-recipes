#!/usr/bin/env bash

unset CONTUR_ROOT
unset CONTUR_DATA_PATH
unset CONTUR_USER_DIR

# reinstate the backup from outside the environment
if [[ -n "${_CONDA_BACKUP_RIVET_DATA_PATH+x}" ]]; then
	export RIVET_DATA_PATH="${_CONDA_BACKUP_RIVET_DATA_PATH}"
	unset _CONDA_BACKUP_RIVET_DATA_PATH
# no backup, just unset
else
	unset RIVET_DATA_PATH
fi

if [[ -n "${_CONDA_BACKUP_RIVET_ANALYSIS_PATH+x}" ]]; then
	export RIVET_ANALYSIS_PATH="${_CONDA_BACKUP_RIVET_ANALYSIS_PATH}"
	unset _CONDA_BACKUP_RIVET_ANALYSIS_PATH
# no backup, just unset
else
	unset RIVET_ANALYSIS_PATH
fi
