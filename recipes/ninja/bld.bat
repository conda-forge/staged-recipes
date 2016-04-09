%PYTHON% configure.py --bootstrap
if errorlevel 1 exit 1

COPY ninja.exe %LIBRARY_BIN%\ninja.exe
if errorlevel 1 exit 1
