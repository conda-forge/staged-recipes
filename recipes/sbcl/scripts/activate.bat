@if defined SBCL_HOME (
    @set "_SBCL_HOME_CONDA_BACKUP=%SBCL_HOME%"
)
@set "SBCL_HOME=%CONDA_PREFIX%\lib\sbcl"

@set "_SBCL_PATH_CONDA_BACKUP=%PATH%"
@set "PATH=%SBCL_HOME%\bin;%PATH%"