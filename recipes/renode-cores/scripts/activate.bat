@echo off
@if defined RENODE_CORES_PATH (
    @set "_RENODE_CORES_PATH_BACKUP=%RENODE_CORES_PATH%"
    :: Remove the last path from the PATH
    @for %%i in ("%RENODE_CORES_PATH%") do @set "PATH=%%~dpi"
)
set RENODE_CORES_PATH=%CONDA_PREFIX%\Library\renode-cores
set "PATH=%RENODE_CORES_PATH%;%PATH%"
