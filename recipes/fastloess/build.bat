cd bindings\python
"%PYTHON%" -m pip install . --no-build-isolation -vv
if errorlevel 1 exit 1
