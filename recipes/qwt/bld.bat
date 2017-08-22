

mkdir build && cd build

qmake ..\qwt.pro
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

mkdir %LIBRARY_PREFIX%\bin
move %LIBRARY_PREFIX%\lib\qwt.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
