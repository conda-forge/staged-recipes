@echo off
setlocal enableextensions

set "SHARE=%PREFIX%\share\bmad-dashboard"
if not exist "%SHARE%" mkdir "%SHARE%"
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

copy /Y "%SRC_DIR%\bmad-dashboard-%PKG_VERSION%.vsix" "%SHARE%\" || exit /b 1
copy /Y "%SRC_DIR%\LICENSE.md"                        "%SHARE%\" || exit /b 1
copy /Y "%RECIPE_DIR%\bmad_dashboard_install.py"      "%SHARE%\" || exit /b 1

REM Windows entry point: a .bat wrapper around the bundled Python helper.
> "%PREFIX%\Scripts\bmad-dashboard-install.bat" (
  echo @echo off
  echo python "%%CONDA_PREFIX%%\share\bmad-dashboard\bmad_dashboard_install.py" %%*
)

exit /b 0
