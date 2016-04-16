setlocal enabledelayedexpansion
cd winbuild

if %ARCH% == 32 (
    set ARCH_STRING=x86
) else (
    set ARCH_STRING=x64
)

:: These are here to map cl.exe version numbers, which we use to figure out which
::   compiler we are using
:: Update this with any new MSVC compiler you might use.
echo @echo 15=9 >> msvc_versions.bat
echo @echo 16=10 >> msvc_versions.bat
echo @echo 19=14 >> msvc_versions.bat

for /f "delims=" %%A in ('cl /? 2^>^&1 ^| findstr /C:"Version"') do set "CL_TEXT=%%A"
FOR /F "tokens=1,2 delims==" %%i IN ('msvc_versions.bat') DO echo %CL_TEXT% | findstr /C:"Version %%i" > nul && set VSTRING=%%j && goto FOUND
EXIT 1
:FOUND

REM This is implicitly using WinSSL.  See Makefile.vc for more info.
nmake /f Makefile.vc mode=dll VC=%VSTRING% WITH_DEVEL=%LIBRARY_PREFIX% WITH_ZLIB=dll DEBUG=no ENABLE_IDN=no MACHINE=%ARCH_STRING%

call :TRIM %VSTRING% VSTRING

robocopy ..\builds\libcurl-vc%VSTRING%-%ARCH_STRING%-release-dll-zlib-dll-ipv6-sspi-winssl\ %LIBRARY_PREFIX% *.* /E
if %ERRORLEVEL% GEQ 8 exit 1

exit /B

:TRIM
  SET %2=%1
  GOTO :EOF
