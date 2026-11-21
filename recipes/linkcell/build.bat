@echo on
bash -euo pipefail "%RECIPE_DIR%\build.sh"
if errorlevel 1 exit 1
