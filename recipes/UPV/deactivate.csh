#!/usr/bin/env csh
#
# Deconfigure a conda environment for UPV
#

if ($?UPV_HTML) then
	setenv UPV_HTML "$CONDA_BACKUP_UPV_HTML"
	unsetenv CONDA_BACKUP_UPV_HTML
else
	unsetenv UPV_HTML
endif
