@echo off
REM First check whether the backup variables are set.
REM The backed up variables are allowed to be set empty.
REM Then restore the backup, and unset the backup.

REM Note that the check whether the backup is set, is essential.
REM There are situations where conda executes the deactivate
REM script without having called the activate script. Without
REM this check, the deactivate script would unset JAVA_HOME in
REM those situations.

REM One such situation occurs when deactivating the environment
REM after installing openjdk for the first time.

if defined LD_LIBRARY_PATH_BACKUP (
    set "LD_LIBRARY_PATH=%LD_LIBRARY_PATH_BACKUP%"
    set "LD_LIBRARY_PATH_BACKUP="
)

if defined CLASSPATH_CONDA_BACKUP (
    set "CLASSPATH=%CLASSPATH_CONDA_BACKUP%"
    set "CLASSPATH_CONDA_BACKUP="
)