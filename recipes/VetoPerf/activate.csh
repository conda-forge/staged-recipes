#!/usr/bin/env csh
#
# Configure a conda environment for Omicron
#

# backup the environment's current setting
if ($?OMICRON_HTML) then
	setenv CONDA_BACKUP_OMICRON_HTML "${OMICRON_HTML}"
endif

# set the variable
setenv OMICRON_HTML "${CONDA_PREFIX}/share/omicron/html"
