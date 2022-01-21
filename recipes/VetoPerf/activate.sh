#!/usr/bin/env bash
#
# Configure a conda environment for VetoPerf
#

# preserve the user's existing setting
if [ ! -z "${VETOPERF_HTML+x}" ]; then
	export CONDA_BACKUP_VETOPERF_HTML="${VETOPERF_HTML}"
fi

# set the variable
export VETOPERF_HTML="${CONDA_PREFIX}/share/vetoperf/html"
