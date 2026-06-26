# Restore CALCHEP to its pre-activation value (see activate.fish).
if set -q CALCHEP_CONDA_BACKUP
    set -gx CALCHEP $CALCHEP_CONDA_BACKUP
    set -e CALCHEP_CONDA_BACKUP
else
    set -e CALCHEP
end
