@echo on

set "OMP_NUM_THREADS=2"
set "TEST_DIR=tests"
set "EXAMPLE_DIR=examples\beam_in_vacuum"

:: executable
hipace.NOMPI.NOACC.DP.LF.exe %EXAMPLE_DIR%\inputs_SI
if errorlevel 1 exit 1

::bash %TEST_DIR%\beam_in_vacuum.SI.Serial.sh hipace.NOMPI.NOACC.DP.LF.exe .
::if errorlevel 1 exit 1
