@echo off

set "INCLUDE=%LIBRARY_INC%;%INCLUDE%"
set "LIB=%LIBRARY_LIB%;%LIB%"

%PYTHON% setup.py build
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt