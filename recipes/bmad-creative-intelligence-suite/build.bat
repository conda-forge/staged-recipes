@echo off
setlocal enabledelayedexpansion

if not exist "src" (
    echo ERROR: src\ directory not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

set SHARE=%PREFIX%\share\bmad-creative-intelligence-suite
if not exist "%SHARE%" mkdir "%SHARE%"
xcopy /E /I /Q src\skills "%SHARE%\skills\"
if errorlevel 1 exit /b 1
copy src\module-help.csv "%SHARE%\"
if errorlevel 1 exit /b 1
copy src\module.yaml "%SHARE%\"
if errorlevel 1 exit /b 1
copy CHANGELOG.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy LICENSE "%SHARE%\"
if errorlevel 1 exit /b 1
copy README.md "%SHARE%\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\bmad_cis_install.py" "%PREFIX%\Scripts\bmad-cis-install-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\bmad-cis-install-script.py" %%*
) > "%PREFIX%\Scripts\bmad-cis-install.bat"
