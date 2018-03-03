@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
if errorlevel 1 exit /B 1

nmake
if errorlevel 1 exit /B 1
nmake test
if errorlevel 1 exit /B 1
nmake install
if errorlevel 1 exit /B 1
