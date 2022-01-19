#!/usr/bin/env csh
#
# Configure a conda environment for VetoPerf
#

# backup the environment's current setting
if ($?VETOPERF_HTML) then
	setenv CONDA_BACKUP_VETOPERF_HTML "${VETOPERF_HTML}"
endif

# set the variable
setenv VETOPERF_HTML "${CONDA_PREFIX}/share/vetoperf/html"
