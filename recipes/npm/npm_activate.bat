@if defined _CONDA_NPM_PATH_BACKUP goto :eof
@set "_CONDA_NPM_PATH_BACKUP=%PATH%"
@set "PATH=%CONDA_PREFIX%\Library\share\npm;%PATH%"
