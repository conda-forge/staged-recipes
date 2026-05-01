@echo off

REM Strip the C extension from pyproject.toml so the wheel is pure-Python
REM (noarch). See strip_ext_modules.py for rationale.
"%PYTHON%" "%RECIPE_DIR%\strip_ext_modules.py"
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
