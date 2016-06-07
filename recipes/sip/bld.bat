%PYTHON% configure.py --sysroot=%PREFIX% --bindir=%LIBRARY_BIN%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
