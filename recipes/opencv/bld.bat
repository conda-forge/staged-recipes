@echo off

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

set OPENCV_ARCH=x86
if "%VSTRING%" == "9" (
    set GENERATOR=Visual Studio 9 2008
    set OPENCV_VC=vc9
)
if "%VSTRING%" == "10" (
    set GENERATOR=Visual Studio 10 2010
    set OPENCV_VC=vc10
)
if "%VSTRING%" == "14" (
    set GENERATOR=Visual Studio 14 2015
    set OPENCV_VC=vc14
)
if not defined GENERATOR EXIT 1

if %ARCH% EQU 64 (
    set GENERATOR=%GENERATOR% Win64
    set OPENCV_ARCH=x64
)

rem I had to take out the PNG_LIBRARY because it included
rem a Windows path which caused it to be wrongly escaped
rem and thus an error. Somehow though, CMAKE still finds
rem the correct png library...
cmake .. -G"%GENERATOR%"                            ^
    -DBUILD_TESTS=0                                 ^
    -DBUILD_DOCS=0                                  ^
    -DBUILD_PERF_TESTS=0                            ^
    -DBUILD_ZLIB=1                                  ^
    -DBUILD_TIFF=1                                  ^
    -DBUILD_PNG=1                                   ^
    -DBUILD_OPENEXR=1                               ^
    -DBUILD_JASPER=1                                ^
    -DBUILD_JPEG=1                                  ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                  ^
    -DPYTHON_INCLUDE_PATH="%PREFIX%\include"        ^
    -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib"   ^
    -DPYTHON_PACKAGES_PATH="%SP_DIR%"               ^
	-DWITH_EIGEN=1                                  ^
    -DWITH_CUDA=0                                   ^
    -DWITH_OPENNI=0                                 ^
    -DWITH_FFMPEG=0                                 ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1

rem Let's just move the files around to a more sane structure (flat)
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\bin\*.dll" "%LIBRARY_BIN%"
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\bin\*.exe" "%LIBRARY_BIN%"
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\lib\*.lib" "%LIBRARY_LIB%"
rmdir "%LIBRARY_PREFIX%\%OPENCV_ARCH%" /S /Q

rem By default cv.py is installed directly in site-packages
rem Therefore, we have to copy all of the dlls directly into it!
xcopy "%LIBRARY_BIN%\opencv*.dll" "%SP_DIR%"

goto :eof

:TRIM
  SetLocal EnableDelayedExpansion
  Call :TRIMSUB %%%1%%
  EndLocal & set %1=%tempvar%
  GOTO :eof

  :TRIMSUB
  set tempvar=%*
  GOTO :eof
