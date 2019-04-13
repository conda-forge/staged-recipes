SET HDF5_DIR=%PREFIX%
"%PYTHON%" -m pip install . --no-deps -vv
if errorlevel 1 exit 1
