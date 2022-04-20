
rem  set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "DEACTIVATE_SCRIPT=%CONDA_PREFIX%\conda-activate-meta\%PKG_UUID%\deactivate-aux.bat"

if exist "%DEACTIVATE_SCRIPT%" do (
  call "%DEACTIVATE_SCRIPT%"
  del "%DEACTIVATE_SCRIPT%"
)
