@echo off
rem First, back up the SCALA_HOME variable if it is set.
rem If it's not set, use the literal string "ENV_VAR_UNSET" as a marker.

if defined SCALA_HOME (
    set "SCALA_HOME_CONDA_BACKUP=%SCALA_HOME%"
) else (
    set "SCALA_HOME_CONDA_BACKUP=ENV_VAR_UNSET"
)

rem Set SCALA_HOME to the appropriate location for this package.
set "SCALA_HOME=%CONDA_PREFIX%\libexec\scala2"
