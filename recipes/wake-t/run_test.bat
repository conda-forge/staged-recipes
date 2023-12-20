@echo on

set "OMP_NUM_THREADS=2"

:: pytest
%PYTHON% -m pytest -s -vvvv tests\
if errorlevel 1 exit 1
