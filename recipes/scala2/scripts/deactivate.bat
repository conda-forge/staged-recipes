@echo off
rem First check whether backup variable(s) is/are set.
rem Variables are allowed to be set empty (indicates unset).
rem If a backup variable is set, restore it and then unset the backup.

if defined SCALA_HOME_CONDA_BACKUP (
    rem A literal value of "ENV_VAR_UNSET" indicates the variable was originally
    rem unset before running the corresponding activate script.
    if "%SCALA_HOME_CONDA_BACKUP%"=="ENV_VAR_UNSET" (
        set "SCALA_HOME="
    ) else (
        set "SCALA_HOME=%SCALA_HOME_CONDA_BACKUP%"
    )
    set "SCALA_HOME_CONDA_BACKUP="
)
