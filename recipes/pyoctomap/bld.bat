@echo on
set PYOCTOMAP_SYSTEM_OCTOMAP=1
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
