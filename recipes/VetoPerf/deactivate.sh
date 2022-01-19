#!/usr/bin/env bash
#
# De-configure a conda environment for Omicron
#

# restore from backup
if [ ! -z "${CONDA_BACKUP_OMICRON_HTML}" ]; then
	export OMICRON_HTML="${CONDA_BACKUP_OMICRON_HTML}"
	unset CONDA_BACKUP_OMICRON_HTML
# no backup, just unset
else
	unset OMICRON_HTML
fi
