# Restore CALCHEP to its pre-activation value (see activate.csh).
if ($?CALCHEP_CONDA_BACKUP) then
    setenv CALCHEP "$CALCHEP_CONDA_BACKUP"
    unsetenv CALCHEP_CONDA_BACKUP
else
    unsetenv CALCHEP
endif
