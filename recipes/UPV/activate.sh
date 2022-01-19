#!/usr/bin/env bash
#
# Configure a conda environment for UPV
#

# preserve the user's existing setting
if [ ! -z "${UPV_HTML+x}" ]; then
	export CONDA_BACKUP_UPV_HTML="${UPV_HTML}"
fi

# set the variable
export UPV_HTML="${CONDA_PREFIX}/share/upv/html"
