cd winbuild

if %ARCH% == 32 (
    set ARCH_STRING=x86
) else (
    set ARCH_STRING=x64
)

REM This is implicitly using WinSSL.  See Makefile.vc for more info.
nmake /f Makefile.vc mode=dll VC=%VS_MAJOR:"=% WITH_DEVEL=%LIBRARY_PREFIX% ^
         WITH_ZLIB=dll DEBUG=no ENABLE_IDN=no MACHINE=%ARCH_STRING%
if %ERRORLEVEL% 1 exit 1

robocopy ..\builds\libcurl-vc%VS_MAJOR:"=%-%ARCH_STRING%-release-dll-zlib-dll-ipv6-sspi-winssl\ %LIBRARY_PREFIX% *.* /E
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
