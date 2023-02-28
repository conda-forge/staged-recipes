@echo on

set "OMP_NUM_THREADS=2"
set "TEST_DIR=example\beam_in_vacuum"

:: executable
impactx.NOMPI.NOACC.DP.exe %TEST_DIR%\inputs_SI
if errorlevel 1 exit 1

