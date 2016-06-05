cd test

sip word.sip
if errorlevel 1 exit 1

%PYTHON% configure.py
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1
