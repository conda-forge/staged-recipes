@echo on

set "OMP_NUM_THREADS=2"
set "TEST_DIR=example\fodo"

:: executable
impactx.NOMPI.NOACC.DP.exe %TEST_DIR%\input_fodo.in
if errorlevel 1 exit 1

:: Python
%PYTHON% %TEST_DIR%\run_fodo.py
if errorlevel 1 exit 1
