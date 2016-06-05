%PYTHON% configure.py --sysroot=%PREFIX% --bindir=%LIBRARY_BIN%

nmake
nmake check
nmake install
