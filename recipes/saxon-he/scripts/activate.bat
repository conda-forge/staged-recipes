@echo off
:: First backup the variables if they are set.
:: The variables are allowed to be empty (Null).
:: Then set the variables to the location of this package.
:: The deactivate script restores the backed up variables.

:: The CLASSPATH is set to the location of the jar files.
set "SaxonHE_HOME=%CONDA_PREFIX%\lib\SaxonHE"

if defined CLASSPATH (
  set "CLASSPATH_CONDA_BACKUP=%CLASSPATH%"
) else (
  set "CLASSPATH="
)

for %%j in (%SaxonHE_HOME%\*.jar) do (
  set "CLASSPATH=%%j;%CLASSPATH%"
)