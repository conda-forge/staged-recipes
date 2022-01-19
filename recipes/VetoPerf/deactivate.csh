#!/usr/bin/env csh
#
# Deconfigure a conda environment for Omicron
#

if ($?OMICRON_HTML) then
	setenv OMICRON_HTML "$CONDA_BACKUP_OMICRON_HTML"
	unsetenv CONDA_BACKUP_OMICRON_HTML
else
	unsetenv OMICRON_HTML
endif
