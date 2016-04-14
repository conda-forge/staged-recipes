set VL_ARCH=win%ARCH%

REM write a temporary batch file to map cl.exe version to visual studio version
echo @echo 15=9 2008> msvc_versions.bat
echo @echo 16=10 2010>> msvc_versions.bat
echo @echo 19=14 2015>> msvc_versions.bat

REM Run cl.exe to find which version our compiler is
for /f "delims=" %%A in ('cl /? 2^>^&1 ^| findstr /C:"Version"') do set "CL_TEXT=%%A"
FOR /F "tokens=1,2 delims==" %%i IN ('msvc_versions.bat') DO echo %CL_TEXT% | findstr /C:"Version %%i" > nul && set VSTRING=%%j && goto FOUND
EXIT 1
:FOUND

REM Trim trailing whitespace that may prevent CMake from finding which generator to use
call :TRIM VSTRING %VSTRING%

REM Set this all manually - will be simpler once the latest conda-build is released
if "%VSTRING%" == "9 2008" (
  set VL_MSVC=9.0
  set VL_MSVS=9
  set VL_MSC=1500
  set MSVSVER=90
) else if "%VSTRING%" == "10 2010" (
  set VL_MSVC=10.0
  set VL_MSVS=10
  set VL_MSC=1700
  set MSVSVER=100
) else if "%VSTRING%" == "14 2015" (
  set VL_MSVC=14.0
  set VL_MSVS=14
  set VL_MSC=1900
  set MSVSVER=140
)

nmake /f Makefile.mak ARCH=%VL_ARCH% VL_MSVC=%VL_MSVC% VL_MSVS=%VL_MSVS%  VL_MSC=%VL_MSC% MSVSVER=%MSVSVER%
if errorlevel 1 exit 1

rem Run tests
bin\\%VL_ARCH%\\test_gauss_elimination
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_getopt_long
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_gmm
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_heap-def
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_host
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_imopv
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_kmeans
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_liop
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_mathop
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_mathop_abs
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_nan
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_qsort-def
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_rand
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_sqrti
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_stringop
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_svd2
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_threads
if errorlevel 1 exit 1
bin\\%VL_ARCH%\\test_vec_comp
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

:TRIM
  SetLocal EnableDelayedExpansion
  set Params=%*
  for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
  exit /B
