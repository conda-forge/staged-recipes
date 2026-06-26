#!/bin/sh
# Export CALCHEP so the CalcHEP engine and downstream packages (e.g. micrOMEGAs)
# can locate the run-in-place installation under $CONDA_PREFIX/share/calchep, and
# so binaries that consult getenv("CALCHEP") are robust against relocation.
# Back up any pre-existing value (a user may point at a hand-built tree).
if [ -n "${CALCHEP:-}" ]; then
    CALCHEP_CONDA_BACKUP="${CALCHEP}"
    export CALCHEP_CONDA_BACKUP
fi
CALCHEP="${CONDA_PREFIX}/share/calchep"
export CALCHEP
