set VL_ARCH="win%ARCH%"

nmake /f Makefile.mak ARCH=%VL_ARCH%
if errorlevel 1 exit 1

copy "bin\%VL_ARCH%\sift.exe" "%LIBRARY_BIN%\sift.exe"
if errorlevel 1 exit 1
copy "bin\%VL_ARCH%\mser.exe" "%LIBRARY_BIN%\mser.exe"
if errorlevel 1 exit 1
copy "bin\%VL_ARCH%\aib.exe"  "%LIBRARY_BIN%\aib.exe"
if errorlevel 1 exit 1

copy "bin\%VL_ARCH%\vl.dll" "%LIBRARY_BIN%\vl.dll"
if errorlevel 1 exit 1
copy "bin\%VL_ARCH%\vl.lib" "%LIBRARY_BIN%\vl.lib"
if errorlevel 1 exit 1

robocopy "vl" "%LIBRARY_INC%\vl" *.h /MIR
if %ERRORLEVEL% GEQ 2 (exit 1) else (exit 0)
