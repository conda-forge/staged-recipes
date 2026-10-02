@echo off

REM Create activation/deactivation directories
if not exist "%PREFIX%\etc\conda\activate.d" mkdir "%PREFIX%\etc\conda\activate.d"
if not exist "%PREFIX%\etc\conda\deactivate.d" mkdir "%PREFIX%\etc\conda\deactivate.d"

REM Copy activation/deactivation scripts
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\intel-gpu-ocl-icd-system-activate.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\intel-gpu-ocl-icd-system-deactivate.bat"

if errorlevel 1 exit 1
