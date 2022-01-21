#!/usr/bin/env bash
#
# De-configure a conda environment for VetoPerf
#

# restore from backup
if [ ! -z "${CONDA_BACKUP_VETOPERF_HTML}" ]; then
	export VETOPERF_HTML="${CONDA_BACKUP_VETOPERF_HTML}"
	unset CONDA_BACKUP_VETOPERF_HTML
# no backup, just unset
else
	unset VETOPERF_HTML
fi
