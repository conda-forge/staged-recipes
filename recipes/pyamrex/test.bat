@echo on

set "OMP_NUM_THREADS=2"


%PYTHON% -m pytest tests/
if errorlevel 1 exit 1
