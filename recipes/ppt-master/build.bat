@echo off
setlocal enabledelayedexpansion

if not exist "skills\ppt-master" (
    echo ERROR: skills\ppt-master\ directory not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

set SHARE=%PREFIX%\share\ppt-master
if not exist "%SHARE%\skills" mkdir "%SHARE%\skills"
xcopy /E /I /Q skills\ppt-master "%SHARE%\skills\ppt-master\"
if errorlevel 1 exit /b 1
copy LICENSE "%SHARE%\"
if errorlevel 1 exit /b 1
copy README.md "%SHARE%\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\ppt_master_install.py" "%PREFIX%\Scripts\ppt-master-install-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\ppt-master-install-script.py" %%*
) > "%PREFIX%\Scripts\ppt-master-install.bat"
