@echo on

mkdir build
cd build

qmake ..\qtserialport.pro
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1
:: No "make check" available
nmake install
if errorlevel 1 exit 1
