@echo off

:: Back up environment variable (only if the variables are set)
if defined PMIP_CBC_LIBRARY (
    set "CONDA_BACKUP_PMIP_CBC_LIBRARY=%PMIP_CBC_LIBRARY%"
)

set "PMIP_CBC_LIBRARY=%PREFIX%\\TODO.dll"
