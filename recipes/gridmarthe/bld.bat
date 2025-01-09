@echo on
setlocal enabledelayedexpansion

mkdir build

:: Windows build script

:: test for new compiler default
:: clang-cl.exe --version
:: if %ERRORLEVEL% neq 0 exit 1
:: 
:: flang-new.exe --version
:: if %ERRORLEVEL% neq 0 exit 1
::

:: Flags for meson, which do not correctly detect flang-new and linkers
:: https://github.com/mesonbuild/meson/issues/12306
set CC=clang-cl
set FC=flang-new
:: by default with llvm-flang, meson still seek gnu ar
set AR=llvm-ar
set LD=lld-link
set FC_LD=lld-link
set CC_LD=lld-link

:: add flags
REM none recognize despite message in log showing possible options...
REM set "FFLAGS=-fdefault-real-8 -ffree-form -fimplicit-none"
:: set "FFLAGS=-std=legacy"
:: -std=legacy not supported : "error: Only -std=f2018 is allowed currently."

REM set "LDFLAGS=-fuse-ld=lld"
REM set "LDFLAGS=%LDFLAGS% -Wl,-Lucrt" // ignored

cd %SRC_DIR%
%PYTHON% -m pip install --no-deps -vvv . ^
    -Cbuild-dir=build ^
    -Csetup-args=-Dcondabuild=true

if %ERRORLEVEL% neq 0 (type build\meson-logs\meson-log.txt && exit 1)

