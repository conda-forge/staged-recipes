@echo on

set "OMP_NUM_THREADS=2"
set "TEST_DIR=tests"

:: executable
bash %TEST_DIR%\beam_in_vacuum.SI.Serial.sh hipace.NOMPI.NOACC.DP.exe .
if errorlevel 1 exit 1
