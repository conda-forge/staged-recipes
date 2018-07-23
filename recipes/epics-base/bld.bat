if %ARCH%==32 (
    set EPICS_HOST_ARCH=win32-x86
) else if %ARCH%==64 (
    set EPICS_HOST_ARCH=windows-x64
)

REM SCRIPTS causes failure of GNU make
set SCRIPTS=

REM set up build
copy %RECIPE_DIR%\pre-build.py %SRC_DIR%
%SYS_PATH% pre-build.py

echo Building at %CD%
mingw32-make clean
mingw32-make

