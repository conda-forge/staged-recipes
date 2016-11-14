setlocal EnableDelayedExpansion

cd build
:: Configure using the CMakeFiles
%LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ./cmake
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1