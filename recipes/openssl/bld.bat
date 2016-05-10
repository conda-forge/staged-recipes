if "%ARCH%"=="32" (
    set OSSL_CONFIGURE=VC-WIN32
    set OSSL_DO_SCRIPT=ms\do_nasm.bat
) ELSE (
    set OSSL_CONFIGURE=VC-WIN64A
    set OSSL_DO_SCRIPT=ms\do_win64a.bat
)

REM Configure step
perl configure %OSSL_CONFIGURE%
if errorlevel 1 exit 1
call %OSSL_DO_SCRIPT%
if errorlevel 1 exit 1

REM Build step
if "%ARCH%"=="64" (
    ml64 -c -Foms\uptable.obj ms\uptable.asm
    if errorlevel 1 exit 1
)

nmake -f ms\nt.mak
if errorlevel 1 exit 1
nmake -f ms\ntdll.mak
if errorlevel 1 exit 1

nmake -f ms\nt.mak test
if errorlevel 1 exit 1
nmake -f ms\ntdll.mak test
if errorlevel 1 exit 1

REM Install step
copy out32\ssleay32.lib %LIBRARY_LIB%\ssleay32_static.lib
copy out32\libeay32.lib %LIBRARY_LIB%\libeay32_static.lib
copy out32dll\ssleay32.lib %LIBRARY_LIB%\ssleay32.lib
copy out32dll\libeay32.lib %LIBRARY_LIB%\libeay32.lib
copy out32dll\ssleay32.dll %LIBRARY_BIN%\ssleay32.dll
copy out32dll\libeay32.dll %LIBRARY_BIN%\libeay32.dll
mkdir %LIBRARY_INC%\openssl
xcopy /S inc32\openssl\*.* %LIBRARY_INC%\openssl\
