#!/usr/bin/env csh
#
# Configure a conda environment for UPV
#

# backup the environment's current setting
if ($?UPV_HTML) then
	setenv CONDA_BACKUP_UPV_HTML "${UPV_HTML}"
endif

# set the variable
setenv UPV_HTML "${CONDA_PREFIX}/share/upv/html"
