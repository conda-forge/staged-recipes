%PYTHON% setup.py build_ext -DUSE_SYSTEM_BLOSC2:BOOL=YES
if errorlevel 1 exit 1
