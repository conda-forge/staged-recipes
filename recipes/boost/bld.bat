:: Set the right msvc version according to Python version
REM write a temporary batch file to map cl.exe version to visual studio version
echo @echo 15=9 > msvc_versions.bat
echo @echo 16=10 >> msvc_versions.bat
echo @echo 17=11 >> msvc_versions.bat
echo @echo 18=12 >> msvc_versions.bat
echo @echo 19=14 >> msvc_versions.bat

REM Run cl.exe to find which version our compiler is
for /f "delims=" %%A in ('cl /? 2^>^&1 ^| findstr /C:"Version"') do set "CL_TEXT=%%A"
FOR /F "tokens=1,2 delims==" %%i IN ('msvc_versions.bat') DO echo %CL_TEXT% | findstr /C:"Version %%i" > nul && set VSTRING=%%j && goto FOUND
EXIT 1
:FOUND

call :TRIM VSTRING %VSTRING%

:: Start with bootstrap
call bootstrap.bat
if errorlevel 1 exit 1

:: Build step
.\b2 install ^
    --build-dir=buildboost ^
    --prefix=%LIBRARY_PREFIX% ^
    toolset=msvc-%VSTRING%.0 ^
    address-model=%ARCH% ^
    variant=release ^
    threading=multi ^
    link=shared ^
    -j%CPU_COUNT% ^
    -s ZLIB_INCLUDE="%LIBRARY_INC%" ^
    -s ZLIB_LIBPATH="%LIBRARY_LIB%"
if errorlevel 1 exit 1

:: Install fix-up for a non version-specific boost include
move %LIBRARY_INC%\boost-1_60\boost %LIBRARY_INC%
if errorlevel 1 exit 1

:: Move dll's to LIBRARY_BIN
move %LIBRARY_LIB%\*vc%VSTRING%0-mt-1_60.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1


:TRIM
  SetLocal EnableDelayedExpansion
  set Params=%*
  for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
  exit /B
