# Export CALCHEP so the CalcHEP engine and downstream packages can locate the
# run-in-place installation. See activate.sh for details.
if set -q CALCHEP
    set -gx CALCHEP_CONDA_BACKUP $CALCHEP
end
set -gx CALCHEP "$CONDA_PREFIX/share/calchep"
