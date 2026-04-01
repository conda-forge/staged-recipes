#!/usr/bin/env csh

unsetenv CONTUR_ROOT
unsetenv CONTUR_DATA_PATH
unsetenv CONTUR_USER_DIR

# reinstate the backup from outside the environment
if ( $?_CONDA_BACKUP_RIVET_DATA_PATH ) then
	setenv RIVET_DATA_PATH "${_CONDA_BACKUP_RIVET_DATA_PATH}"
	unsetenv _CONDA_BACKUP_RIVET_DATA_PATH
# no backup, just unset
else
	unsetenv RIVET_DATA_PATH
endif

if ( $?_CONDA_BACKUP_RIVET_ANALYSIS_PATH ) then
	setenv RIVET_ANALYSIS_PATH "${_CONDA_BACKUP_RIVET_ANALYSIS_PATH}"
	unsetenv _CONDA_BACKUP_RIVET_ANALYSIS_PATH
# no backup, just unset
else
	unsetenv RIVET_ANALYSIS_PATH
endif
