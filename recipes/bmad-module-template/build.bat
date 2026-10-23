@echo off
setlocal enabledelayedexpansion

if not exist "README.md" (
    echo ERROR: README.md not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

set SHARE=%PREFIX%\share\bmad-module-template
if not exist "%SHARE%" mkdir "%SHARE%"
xcopy /E /I /Q .claude-plugin "%SHARE%\.claude-plugin\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q skills "%SHARE%\skills\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q docs "%SHARE%\docs\"
if errorlevel 1 exit /b 1
copy README.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy LICENSE "%SHARE%\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\bmad_module_template_init.py" "%PREFIX%\Scripts\bmad-module-template-init-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\bmad-module-template-init-script.py" %%*
) > "%PREFIX%\Scripts\bmad-module-template-init.bat"
