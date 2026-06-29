# Export CALCHEP so the CalcHEP engine and downstream packages can locate the
# run-in-place installation. See activate.sh for details.
if ($?CALCHEP) then
    setenv CALCHEP_CONDA_BACKUP "$CALCHEP"
endif
setenv CALCHEP "${CONDA_PREFIX}/share/calchep"
