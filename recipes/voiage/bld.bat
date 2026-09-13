@echo on
set "GIT_DIR=%SRC_DIR%\.conda-no-git"
"%PYTHON%" -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit /b 1
