@echo off
REM First backup the variables if they are set.
REM The variables are allowed to be empty (Null).
REM Then set the variables to the location of this package.
REM The deactivate script restores the backed up variables.

REM The CLASSPATH is set to the location of the jar files.
set "SaxonHE_HOME=%CONDA_PREFIX%\lib\SaxonHE"

if defined LD_LIBRARY_PATH (
  set "LD_LIBRARY_PATH_BACKUP=%LD_LIBRARY_PATH%"
  set "LD_LIBRARY_PATH=%SaxonHE_HOME%\lib;%LD_LIBRARY_PATH%"
) else (
  set "LD_LIBRARY_PATH=%SaxonHE_HOME%\lib"
)

if defined CLASSPATH (
  set "CLASSPATH_CONDA_BACKUP=%CLASSPATH%"
) else (
  set "CLASSPATH="
)

for %%j in (%SaxonHE_HOME%\*.jar) do (
  set "CLASSPATH=%%j;%CLASSPATH%"
)