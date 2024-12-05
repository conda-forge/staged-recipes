@echo off
:: First check whether the backup variables are set.
:: The backed up variables are allowed to be set empty.
:: Then restore the backup, and unset the backup.

:: Note that the check whether the backup is set, is essential.
:: There are situations where conda executes the deactivate
:: script without having called the activate script. Without
:: this check, the deactivate script would unset JAVA_HOME in
:: those situations.

:: One such situation occurs when deactivating the environment
:: after installing openjdk for the first time.

if defined CLASSPATH_CONDA_BACKUP (
    set "CLASSPATH=%CLASSPATH_CONDA_BACKUP%"
    set "CLASSPATH_CONDA_BACKUP="
)