@echo on

:: Build script for libp11, referenced from recipe.yaml via
:: `build: script: file:`. Uses the upstream nmake/MSVC build path
:: (see INSTALL.md, "Windows Build"). nmake, rc and link are
:: provided by the Visual Studio environment of the conda-forge
:: build machine; the OpenSSL headers and libcrypto.lib come from
:: the openssl host package.

setlocal enabledelayedexpansion

:: Set as environment variables so the recursive nmake call into
:: src/ inherits them. OPENSSL_DIR must contain include\ and
:: lib\libcrypto.lib, which is the conda-forge prefix layout.
set "BUILD_FOR=WIN64"
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

nmake /f Makefile.mak
if %ERRORLEVEL% neq 0 exit /b 1

:: The upstream nmake build has no install target, so mirror the
:: autotools layout (lib/, include/, lib/pkgconfig/) by hand.
:: cmd.exe gotchas from the first win-64 CI round: a multi-source
:: `copy ... %LIBRARY_INC%\` (several files + trailing-backslash
:: destination) aborted with "The syntax of the command is
:: incorrect.", so copy one file per line, quote every path, and
:: never end a line with a bare backslash.
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
if not exist "%LIBRARY_INC%" mkdir "%LIBRARY_INC%"

copy /Y src\libp11.dll "%LIBRARY_BIN%"
if %ERRORLEVEL% neq 0 exit /b 1
copy /Y src\libp11.lib "%LIBRARY_LIB%"
if %ERRORLEVEL% neq 0 exit /b 1
copy /Y src\libp11.h "%LIBRARY_INC%"
if %ERRORLEVEL% neq 0 exit /b 1
copy /Y src\p11_err.h "%LIBRARY_INC%"
if %ERRORLEVEL% neq 0 exit /b 1
copy /Y src\p11_ver.h "%LIBRARY_INC%"
if %ERRORLEVEL% neq 0 exit /b 1

:: The PKCS#11 engine and OpenSSL provider modules. On unix the
:: conda-forge build installs them into lib/ossl-modules (the
:: enginesdir/modulesdir of the openssl .pc); mirror that.
if not exist "%LIBRARY_LIB%\ossl-modules" mkdir "%LIBRARY_LIB%\ossl-modules"
copy /Y src\pkcs11.dll "%LIBRARY_LIB%\ossl-modules"
if %ERRORLEVEL% neq 0 exit /b 1
copy /Y src\pkcs11prov.dll "%LIBRARY_LIB%\ossl-modules"
if %ERRORLEVEL% neq 0 exit /b 1

:: pkg-config metadata mirroring the unix build (src/libp11.pc.in).
:: prefix is %PREFIX%\Library, the conda-forge win convention (the
:: fmt package ships fmt.pc with the same prefix).
if not exist "%LIBRARY_LIB%\pkgconfig" mkdir "%LIBRARY_LIB%\pkgconfig"
(
echo prefix=%PREFIX%\Library
echo exec_prefix=${prefix}
echo libdir=${exec_prefix}/lib
echo includedir=${prefix}/include
echo.
echo Name: libp11
echo Description: High-level wrapper around the PKCS#11 API
echo Version: 0.4.21
echo Libs: -L${libdir} -lp11
echo Libs.private: -lcrypto
echo Cflags: -I${includedir}
) > "%LIBRARY_LIB%\pkgconfig\libp11.pc"
if %ERRORLEVEL% neq 0 exit /b 1
