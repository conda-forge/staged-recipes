@echo off

:: Unset environment variable that was set upon environment activation.
if exist "%CONDA_BACKUP_PMIP_CBC_LIBRARY%" (
    set "PMIP_CBC_LIBRARY=%CONDA_BACKUP_PMIP_CBC_LIBRARY%"
    set CONDA_BACKUP_PMIP_CBC_LIBRARY=
) else (
    set PMIP_CBC_LIBRARY=
)
