#!/usr/bin/env bash
#
# De-configure a conda environment for UPV
#

# restore from backup
if [ ! -z "${CONDA_BACKUP_UPV_HTML}" ]; then
	export UPV_HTML="${CONDA_BACKUP_UPV_HTML}"
	unset CONDA_BACKUP_UPV_HTML
# no backup, just unset
else
	unset UPV_HTML
fi
