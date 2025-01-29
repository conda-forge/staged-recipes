@echo on
setlocal enabledelayedexpansion

mkdir build

REM Windows build script

REM Flags for meson, which do not correctly detect flang-new and linkers
REM https://github.com/mesonbuild/meson/issues/12306

set LD=lld-link
set FC_LD=lld-link
set CC_LD=lld-link

REM ---- BUILD with meson backend and pip
cd %SRC_DIR%
%PYTHON% -m pip install --no-deps -vvv . ^
    -Cbuild-dir=build ^
    -Csetup-args=-Dcondabuild=true

if %ERRORLEVEL% neq 0 (type build\meson-logs\meson-log.txt && exit 1)

