mkdir build
cd build

set CMAKE_CONFIG="Release"

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

if "%VSTRING%" == "9" (
    set GENERATOR=Visual Studio 9 2008

    if %ARCH% EQU 64 (
      rem Handle the case whereby Visual Studio 2008 Express does not properly
      rem support the x64 compiler.
      call %RECIPE_DIR%\vs2008\setup_x64.bat
      md "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\amd64"
      copy "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\vcvars64.bat" "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\amd64\vcvarsamd64.bat"
    )
)
if "%VSTRING%" == "10" (
    set GENERATOR=Visual Studio 10 2010
)
if "%VSTRING%" == "14" (
    set GENERATOR=Visual Studio 14 2015
)
if not defined GENERATOR EXIT 1

if %ARCH% EQU 64 (
    set GENERATOR=%GENERATOR% Win64
)

cmake .. -LAH -G"%GENERATOR%"        ^
 -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG%   ^
 -DINCLUDE_INSTALL_DIR=%LIBRARY_INC% ^
 -DLIB_INSTALL_DIR=%LIBRARY_LIB%     ^
 -DBIN_INSTALL_DIR=%LIBRARY_BIN%

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

rem Just make the basic tests as all the tests take too long to run.
FOR /L %%A IN (1,1,7) DO (
  cmake --build . --config %CMAKE_CONFIG% --target basicstuff_%%A
)
ctest -R basicstuff*
if errorlevel 1 exit 1
goto :eof

:TRIM
  SetLocal EnableDelayedExpansion
  Call :TRIMSUB %%%1%%
  EndLocal & set %1=%tempvar%
  GOTO :eof

  :TRIMSUB
  set tempvar=%*
  GOTO :eof
