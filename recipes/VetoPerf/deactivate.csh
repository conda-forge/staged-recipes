#!/usr/bin/env csh
#
# Deconfigure a conda environment for VetoPerf
#

if ($?VETOPERF_HTML) then
	setenv VETOPERF_HTML "$CONDA_BACKUP_VETOPERF_HTML"
	unsetenv CONDA_BACKUP_VETOPERF_HTML
else
	unsetenv VETOPERF_HTML
endif
