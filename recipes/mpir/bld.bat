REM write a temporary batch file to map cl.exe version to visual studio version
echo @echo 16=10>> msvc_versions.bat
echo @echo 19=14>> msvc_versions.bat

REM Run cl.exe to find which version our compiler is
for /f "delims=" %%A in ('cl /? 2^>^&1 ^| findstr /C:"Version"') do set "CL_TEXT=%%A"
FOR /F "tokens=1,2 delims==" %%i IN ('msvc_versions.bat') DO echo %CL_TEXT% | findstr /C:"Version %%i" > nul && set VSTRING=%%j && goto FOUND
EXIT 1
:FOUND

REM Trim trailing whitespace that may prevent CMake from finding which generator to use
call :TRIM VSTRING %VSTRING%

cd build.vc%VSTRING%

if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)


msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release lib_mpir_gc\lib_mpir_gc.vcxproj
msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release lib_mpir_cxx\lib_mpir_cxx.vcxproj

mkdir %PREFIX%\mpir\lib\%PLATFORM%\Release

cd ..

copy lib\%PLATFORM%\Release\mpir.lib lib\%PLATFORM%\Release\gmp.lib
copy lib\%PLATFORM%\Release\mpirxx.lib lib\%PLATFORM%\Release\gmpxx.lib

xcopy lib %PREFIX%\mpir\lib\ /E

:TRIM
  SetLocal EnableDelayedExpansion
  set Params=%*
  for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
  exit /B
